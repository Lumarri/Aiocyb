// Browser validation of the compiled offline curriculum and contextual portraits.
const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const { chromium } = require(process.env.AIOCYB_PLAYWRIGHT || 'playwright');
const root = path.resolve(__dirname, '..');
const base = process.env.AIOCYB_PREVIEW_URL || 'http://127.0.0.1:8893';
const read = name => JSON.parse(fs.readFileSync(path.join(root, name), 'utf8'));
const courseIds = ['linux-start', 'terminal-tools', 'linux-access', 'linux-operations', 'log-analysis', 'linux-investigation'];
const courses = courseIds.map(id => read('assets/linux/' + id + '.json'));
const first = courses[0], finalLesson = first.lessons[9];
const scores = Object.fromEntries(['digital-life', 'risk-routine', 'passwords', 'mfa', 'phishing-signals', 'safe-response'].map(id => [id, 3]));
for (const folder of ['courses', 'practice', 'malware', 'secure']) {
  for (const name of fs.readdirSync(path.join(root, 'assets', folder)).filter(name => name.endsWith('.json'))) {
    for (const lesson of read('assets/' + folder + '/' + name).lessons) scores[lesson.id] = lesson.questions.length;
  }
}
assert.equal(Object.keys(scores).length, 370);
for (const lesson of first.lessons.slice(0, 9)) scores[lesson.id] = 3;
const regexMarks = new Set('.*+?^$()[]{}|' + String.fromCharCode(92));
const escape = value => [...value].map(c => regexMarks.has(c) ? String.fromCharCode(92) + c : c).join('');

(async () => {
  const browser = await chromium.launch({ headless: true, ...(process.env.AIOCYB_CHROMIUM ? { executablePath: process.env.AIOCYB_CHROMIUM } : {}) });
  const context = await browser.newContext({ viewport: { width: 390, height: 844 } });
  const page = await context.newPage();
  const errors = [];
  let blocked = 0;
  const report = { viewport: '390x844', courses: [], expressions: [], screenshots: [], errors };
  page.on('pageerror', error => errors.push(error.message));
  await page.route('**/*', route => {
    const url = route.request().url();
    if (url.startsWith('http') && new URL(url).origin !== new URL(base).origin) { blocked++; return route.abort(); }
    return route.continue();
  });
  await page.addInitScript(initial => {
    if (!localStorage.getItem('aiocyb.academy.v1')) localStorage.setItem('aiocyb.academy.v1', JSON.stringify(JSON.stringify(initial)));
  }, { onboarded: true, name: 'Alex', darkMode: true, neonTheme: 'violet', neonGlow: true, lastLessonId: finalLesson.id, scores, heardDialogueIds: [], mistakeCounts: {} });
  const saved = () => page.evaluate(() => JSON.parse(JSON.parse(localStorage.getItem('aiocyb.academy.v1'))));
  const expectText = text => page.waitForFunction(target => {
    const clean = value => value.replace(/\s+/g, ' ').trim();
    return Array.from(document.querySelectorAll('flt-semantics,input,textarea')).some(e => clean((e.getAttribute('aria-label') || '') + (e.innerText || '') + (e.value || '')).includes(clean(target)));
  }, text, { timeout: 12000 });
  const click = async name => {
    const role = typeof name === 'string' && ['Inicio', 'Cursos', 'Explorar', 'Mi progreso', 'Ajustes'].includes(name) ? 'tab' : 'button';
    await page.getByRole(role, { name, exact: typeof name === 'string' }).click();
    await page.waitForTimeout(450);
  };
  const back = async () => {
    await page.getByRole('button', { name: /^(Atrás|Back|Volver)$/ }).evaluate(element => element.click());
    await page.waitForTimeout(650);
  };
  const semantics = async () => {
    await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics[role="button"]'));
    const trigger = page.locator('flt-semantics-placeholder');
    if (await trigger.count()) await trigger.evaluate(e => e.click());
  };
  const capture = async (name, expression) => {
    await page.mouse.move(380, 40); await page.waitForTimeout(2200);
    await page.screenshot({ path: path.join(root, 'docs/screenshots', name) });
    report.screenshots.push(name);
    if (expression && !report.expressions.includes(expression)) report.expressions.push(expression);
  };
  const noControls = async () => {
    for (const text of ['Otra explicación', 'Conversación guardada', 'Desactivar diálogos irónicos']) assert.equal(await page.getByRole('button', { name: text, exact: true }).count(), 0);
  };
  const routes = async () => { await click('Explorar'); await click(/^Rutas de aprendizaje/); await expectText('Linux: observa, comprende e investiga'); };
  try {
    await page.goto(base, { waitUntil: 'networkidle' }); await semantics();
    await routes();
    await page.mouse.move(200, 650); await page.mouse.wheel(0, 5000); await page.waitForTimeout(500);
    await capture('32-ruta-linux.png');
    for (const course of courses) {
      await click(new RegExp(escape(course.title)));
      await expectText('40 ejercicios');
      const lesson = course.lessons[0];
      await click(new RegExp(escape(lesson.title))); await expectText(lesson.aoi.intro);
      await expectText('curiosa, con la cabeza');
      if (course === first) { await capture('33-aoi-curiosidad.png', 'curious'); await click('Guardar en biblioteca'); }
      await page.getByRole('checkbox', { name: 'Teoría', exact: true }).click();
      await expectText(lesson.sections[0].body); await expectText(lesson.aoi.theory0);
      await expectText('concentrada, con un lápiz');
      if (course === first) {
        await capture('34-aoi-concentracion.png', 'focused');
        for (let i = 0; i < 3; i++) await click('Siguiente');
        await expectText(lesson.aoi.theory3); await expectText('retándote con una sonrisa');
        await capture('35-aoi-reto.png', 'playful');
      }
      await page.getByRole('checkbox', { name: 'Casos', exact: true }).click();
      await expectText(lesson.cases[0].explanation); await expectText(lesson.aoi.case0);
      await expectText('sorprendida por un descubrimiento');
      if (course === first) await capture('36-aoi-sorpresa.png', 'surprised');
      await click('Siguiente'); await expectText(lesson.cases[1].explanation); await noControls();
      await back(); await back();
      report.courses.push({ id: course.id, theoryRead: true, workedCases: 2, exercises: 40 });
    }
    await click(new RegExp(escape(first.title)));
    await click(new RegExp(escape(finalLesson.title))); await click('Practicar · 4 ejercicios');
    for (let attempt = 0; attempt < 3; attempt++) {
      await click('Dame una pista'); await expectText(finalLesson.questions[0].aoi.hint);
      for (let index = 0; index < 4; index++) {
        const q = finalLesson.questions[index];
        const wrong = attempt === 0 ? index < 2 : attempt === 1 && index === 0;
        await expectText(q.scenario); await click(q.options[wrong ? (q.answer + 1) % 3 : q.answer]);
        await click('Comprobar respuesta');
        await expectText(q.aoi[wrong ? (attempt === 0 ? 'soft' : 'sharp') : 'correct']);
        await expectText(wrong ? q.wrongExplanations[(q.answer + 1) % 3] : q.explanation);
        if (attempt === 0 && index === 0) { await expectText('puchero teatral'); await capture('37-aoi-primer-fallo.png', 'pouting'); }
        if (attempt === 0 && index === 2) { await expectText('aliviada, con una sonrisa'); await capture('38-aoi-alivio.png', 'relieved'); }
        if (attempt === 1 && index === 0) { await expectText('exasperación cómica'); await capture('39-aoi-reincidencia.png'); }
        await click(index === 3 ? 'Ver mi resultado' : 'Siguiente ejercicio');
      }
      await expectText((attempt + 2) + ' / 4');
      if (attempt === 0) { assert.equal((await saved()).scores[finalLesson.id], 2); }
      if (attempt === 1) { await expectText(first.closure.text); await expectText('celebrando el curso'); await capture('40-aoi-celebracion-linux.png', 'celebrating'); }
      if (attempt === 2) { await expectText(finalLesson.aoi.pass); await expectText('rubor pícaro'); await capture('41-aoi-rubor.png', 'blushing'); }
      await noControls();
      if (attempt < 2) await click('Volver a practicar');
    }
    await page.reload({ waitUntil: 'networkidle' }); await semantics();
    const data = await saved();
    assert.equal(data.scores[finalLesson.id], 4);
    for (const [id, value] of Object.entries(scores)) assert.equal(data.scores[id], value);
    assert.equal(data.mistakeCounts[finalLesson.id + ':0'], 2);
    assert.equal(data.mistakeCounts[finalLesson.id + ':1'], 1);
    assert(data.favoriteLessons.includes(first.lessons[0].id));
    assert.equal(data.neonTheme, 'violet');
    assert.deepEqual(errors, []);
    assert.equal(report.expressions.length, 8);
    report.previousGradesRetained = 370;
    report.courseCompletedAtThreeOfFour = true;
    report.bestScorePersisted = 4;
    report.mistakesPersisted = true;
    report.bookmarkPersisted = true;
    report.noManualDialogueControls = true;
    report.blockedExternalRequests = blocked;
    fs.writeFileSync(path.join(root, 'docs/LINUX_BROWSER_AUDIT.json'), JSON.stringify(report, null, 2) + '\n');
    console.log(JSON.stringify(report));
  } catch (error) {
    console.error('Original browser failure:', error);
    try {
      await page.screenshot({ path: path.join(root, 'docs/screenshots/linux-smoke-failure.png') });
      console.error(await page.getByRole('button').evaluateAll(elements => elements.map(e => e.getAttribute('aria-label') || e.innerText)));
    } catch (diagnosticError) { console.error('Diagnostic capture failed:', diagnosticError.message); }
    throw error;
  } finally { await context.close(); await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
