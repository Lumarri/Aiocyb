// Serve build/web locally. Playwright and Chromium may be supplied externally.
const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const { chromium } = require(process.env.AIOCYB_PLAYWRIGHT || 'playwright');
const root = path.resolve(__dirname, '..');
const base = process.env.AIOCYB_PREVIEW_URL || 'http://127.0.0.1:8893';
const read = name => JSON.parse(fs.readFileSync(path.join(root, name), 'utf8'));
const course = read('assets/secure/crypto-foundations.json');
const labs = read('docs/LAB_CONTENT_AUDIT.json').data;
const courseIds = ['crypto-foundations', 'keys-data', 'web-security', 'secure-coding'];
const legacyIds = ['digital-life', 'risk-routine', 'passwords', 'mfa', 'phishing-signals', 'safe-response'];
const regexMarks = new Set('.*+?^$()[]{}|' + String.fromCharCode(92));
const escape = value => [...value].map(character => regexMarks.has(character) ? String.fromCharCode(92) + character : character).join('');

(async () => {
  const browser = await chromium.launch({ headless: true,
    ...(process.env.AIOCYB_CHROMIUM ? { executablePath: process.env.AIOCYB_CHROMIUM } : {}),
  });
  const context = await browser.newContext({ viewport: { width: 390, height: 844 } });
  const page = await context.newPage();
  const errors = [];
  let blocked = 0;
  const seededScores = Object.fromEntries([
    ...legacyIds.map(id => [id, 3]),
    ...course.lessons.slice(0, 9).map(lesson => [lesson.id, 2]),
  ]);
  const reviewedLesson = course.lessons[0];
  const reviewIndex = 2;
  const reviewQuestion = reviewedLesson.questions[reviewIndex];
  const lastLesson = course.lessons[9];
  const report = { viewport: '390x844', sections: [], labs: [], courses: [], screenshots: [], errors };
  page.on('pageerror', error => errors.push(error.message));
  await page.route('**/*', route => {
    const url = route.request().url();
    if (url.startsWith('http') && new URL(url).origin !== new URL(base).origin) {
      blocked++;
      return route.abort();
    }
    return route.continue();
  });
  await page.addInitScript(initial => {
    if (!localStorage.getItem('aiocyb.academy.v1')) {
      localStorage.setItem('aiocyb.academy.v1', JSON.stringify(JSON.stringify(initial)));
    }
  }, { onboarded: true, name: 'Alex', darkMode: true, neonTheme: 'cyan', neonGlow: true,
    lastLessonId: lastLesson.id, scores: seededScores, heardDialogueIds: [],
    mistakeCounts: { [reviewedLesson.id + ':' + reviewIndex]: 1, 'diagnostic:4': 1 },
  });
  const saved = () => page.evaluate(() => JSON.parse(JSON.parse(localStorage.getItem('aiocyb.academy.v1'))));
  const expectText = text => page.waitForFunction(target => {
    const normalize = value => value.replace(/\s+/g, ' ').trim();
    return Array.from(document.querySelectorAll('flt-semantics,input,textarea'))
      .some(element => normalize((element.getAttribute('aria-label') || '') + (element.innerText || '') + (element.value || '') + (element.getAttribute('aria-valuetext') || '')).includes(normalize(target)));
  }, text, { timeout: 10000 });
  const click = async name => {
    const role = typeof name === 'string' && ['Inicio', 'Cursos', 'Explorar', 'Mi progreso', 'Configuración'].includes(name) ? 'tab' : 'button';
    await page.getByRole(role, { name: name === 'Configuración' ? 'Ajustes' : name, exact: typeof name === 'string' }).click();
    await page.waitForTimeout(100);
  };
  const back = () => click(/^(Atrás|Back|Volver)$/);
  const enableSemantics = async () => {
    await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics[role="button"]'));
    const trigger = page.locator('flt-semantics-placeholder');
    if (await trigger.count()) await trigger.evaluate(element => element.click());
  };
  const capture = async name => {
    await page.mouse.move(380, 40);
    await page.waitForTimeout(800);
    await page.screenshot({ path: path.join(root, 'docs/screenshots', name) });
    report.screenshots.push(name);
  };
  const noControls = async () => {
    for (const name of ['Otra explicación', 'Conversación guardada', 'Releer explicaciones vistas', 'Desactivar diálogos irónicos']) {
      assert.equal(await page.getByRole('button', { name, exact: true }).count(), 0);
    }
  };
  const section = async title => {
    await click('Explorar');
    await click(new RegExp('^' + escape(title)));
    await expectText(title);
    if (!report.sections.includes(title)) report.sections.push(title);
  };
  try {
    await page.goto(base, { waitUntil: 'networkidle' });
    await enableSemantics();
    await click('Explorar');
    await expectText('Más formas de aprender.');
    await capture('24-explorar-neon-cian.png');
    await click('Configuración');
    await page.getByRole('checkbox', { name: 'Neón violeta', exact: true }).click();
    await page.getByRole('switch', { name: /Brillo suave/ }).click();
    await page.waitForTimeout(150);
    assert.equal((await saved()).neonTheme, 'violet');
    assert.equal((await saved()).neonGlow, false);
    await capture('25-ajustes-neon-violeta.png');
    await page.reload({ waitUntil: 'networkidle' });
    await enableSemantics();
    assert.equal((await saved()).neonTheme, 'violet');
    assert.equal((await saved()).neonGlow, false);
    report.themePersistedAfterReload = true;
    await section('Rutas de aprendizaje');
    await expectText('Construye seguridad');
    await capture('26-rutas-aprendizaje.png');
    await back();

    await section('Laboratorio offline');
    for (const lab of labs) {
      await click(new RegExp(escape(lab.title)));
      for (let index = 0; index < 3; index++) {
        const stage = lab.stages[index];
        await expectText(stage.evidence);
        await expectText(stage.intro);
        if (lab === labs[0] && index === 0) {
          for (let attempt = 0; attempt < 2; attempt++) {
            await click(stage.options[(stage.answer + 1) % 3]);
            await click('Probar decisión');
            await expectText(attempt ? stage.sharp : stage.soft);
            if (attempt) await capture('27-laboratorio-reincidencia.png');
            await click('Revisar mi decisión');
          }
        }
        await click(stage.options[stage.answer]);
        await click('Probar decisión');
        await expectText(stage.correct);
        await click(index === 2 ? 'Terminar simulación' : 'Siguiente etapa');
      }
      await expectText(lab.closure);
      assert((await saved()).completedLabs.includes(lab.id));
      await noControls();
      report.labs.push({ id: lab.id, stagesCompleted: 3 });
      await click('Volver al laboratorio');
    }
    assert.deepEqual((await saved()).scores, seededScores, 'Labs changed course grades');
    assert.equal((await saved()).labMistakes['protection:0'], 2);
    await back();

    await section('Biblioteca');
    const search = page.getByRole('textbox', { name: 'Buscar en la biblioteca', exact: true });
    await search.click();
    await page.waitForTimeout(150);
    await search.pressSequentially('técnicas que permiten construir', { delay: 15 });
    await expectText('1 lección encontrada');
    await click('Guardar en biblioteca');
    await page.getByRole('checkbox', { name: 'Solo favoritos', exact: true }).click();
    await expectText(reviewedLesson.title);
    await capture('28-biblioteca-favoritos.png');
    await click(new RegExp(escape(reviewedLesson.title)));
    const theoryWords = reviewedLesson.sections.reduce((sum, part) => sum + part.body.trim().split(/\s+/).length, 0);
    await expectText('TEORÍA PROFUNDA · ' + theoryWords + ' palabras');
    assert.equal((await saved()).favoriteLessons[0], reviewedLesson.id);
    await noControls();
    await back(); await back();

    await section('Repaso de errores');
    await click(new RegExp(escape(reviewQuestion.prompt)));
    await expectText(reviewQuestion.aoi.question);
    await click('Dame una pista'); await expectText(reviewQuestion.aoi.hint);
    await click(reviewQuestion.options[reviewQuestion.answer]); await click('Comprobar respuesta');
    await expectText(reviewQuestion.aoi.correct);
    await capture('29-repaso-resuelto.png');
    await click('Volver al repaso');
    await click(/MFA que no iniciaste/);
    await click('La rechazo y reviso la cuenta'); await click('Comprobar respuesta');
    await expectText('Repaso resuelto.'); await click('Volver al repaso');
    await expectText('0 ejercicios pendientes.');
    assert.deepEqual((await saved()).scores, seededScores, 'Review changed course grades');
    assert.equal((await saved()).reviewedMistakes[reviewedLesson.id + ':2'], 1);
    assert.equal((await saved()).reviewedMistakes['diagnostic:4'], 1);
    report.reviewResolvedWithoutChangingGrades = true;
    await back();

    await section('Logros');
    await expectText('Cuatro experimentos'); await expectText('Conseguido');
    await capture('30-logros-reales.png'); await back();

    for (const id of courseIds) {
      const current = read('assets/secure/' + id + '.json');
      await section('Rutas de aprendizaje');
      await click(new RegExp(escape(current.title)));
      await expectText('30 ejercicios');
      await click(new RegExp(escape(current.lessons[0].title)));
      await page.getByRole('checkbox', { name: 'Teoría', exact: true }).click();
      await expectText(current.lessons[0].sections[0].body);
      await page.getByRole('checkbox', { name: 'Casos', exact: true }).click();
      await expectText(current.lessons[0].cases[0].explanation);
      await click('Siguiente'); await expectText(current.lessons[0].cases[1].explanation);
      await back(); await back(); await back();
      report.courses.push({ id, theoryRead: true, workedCases: 2, exercises: 30 });
    }

    await section('Rutas de aprendizaje');
    await click(new RegExp(escape(course.title)));
    await click(new RegExp(escape(lastLesson.title)));
    await expectText(lastLesson.title); await click('Practicar · 3 ejercicios');
    for (let index = 0; index < 3; index++) {
      const q = lastLesson.questions[index];
      await expectText(q.scenario); await expectText(q.aoi.question);
      await click(q.options[index === 0 ? (q.answer + 1) % 3 : q.answer]);
      await click('Comprobar respuesta');
      await expectText(q.aoi[index === 0 ? 'soft' : 'correct']);
      await click(index === 2 ? 'Ver mi resultado' : 'Siguiente ejercicio');
    }
    await expectText('2 / 3'); await expectText(course.closure.text);
    await capture('31-curso-nuevo-completado.png'); await noControls();
    await page.reload({ waitUntil: 'networkidle' });
    const data = await saved();
    assert.equal(data.scores[lastLesson.id], 2);
    for (const [id, score] of Object.entries(seededScores)) assert.equal(data.scores[id], score);
    assert.equal(data.neonTheme, 'violet'); assert.equal(data.neonGlow, false);
    assert(data.favoriteLessons.includes(reviewedLesson.id));
    assert.equal(data.completedLabs.length, 4);
    assert.equal(data.reviewedMistakes[reviewedLesson.id + ':2'], 1);
    assert.deepEqual(errors, []);
    report.finalScore = '2/3'; report.courseCompleted = true;
    report.previousGradesRetained = true; report.labsAwardNoCourseXP = true;
    report.persistedAfterReload = true; report.blockedExternalRequests = blocked;
    fs.writeFileSync(path.join(root, 'docs/EXPERIENCE_BROWSER_AUDIT.json'), JSON.stringify(report, null, 2) + '\n');
    console.log(JSON.stringify(report));
  } catch (error) {
    await page.screenshot({ path: path.join(root, 'docs/screenshots/experience-smoke-failure.png') });
    console.error(await page.getByRole('button').evaluateAll(elements => elements.map(e => e.getAttribute('aria-label') || e.innerText)));
    throw error;
  } finally {
    await context.close(); await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
