// Exercise the compiled 1.7 network expansion offline with existing local grades.
const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');
const { chromium } = require(process.env.AIOCYB_PLAYWRIGHT || 'playwright');
const root = path.resolve(__dirname, '..');
const base = process.env.AIOCYB_PREVIEW_URL || 'http://127.0.0.1:8896';
const version = fs.readFileSync(path.join(root, 'pubspec.yaml'), 'utf8').match(/^version:\s*(\S+)/m)[1];
const screenshotFolder = `${version.split('.').slice(0, 2).join('.')}-networks`;
const read = file => JSON.parse(fs.readFileSync(path.join(root, file), 'utf8').replace(/^\uFEFF/, ''));
const courseIds = ['ipv4-subnetting', 'ipv6-foundations', 'switching-routing',
  'network-diagnostics', 'network-defense', 'security-operations'];
const reinforcedIds = ['networks-basics', 'ip-dns', 'home-wifi',
  'public-networks', 'safe-browsing', 'web-privacy'];
const expansion = courseIds.map(id => read(`assets/network_expansion/${id}.json`));
const existing = reinforcedIds.map(id => read(`assets/courses/${id}.json`));
const practice = new Map();
for (const id of reinforcedIds) {
  let current;
  for (const line of fs.readFileSync(path.join(root, `assets/network_expansion/${id}.practice.md`), 'utf8').split(/\r?\n/)) {
    if (line.startsWith('@practice ')) {
      const fields = line.slice(10).split('|').map(value => value.trim());
      current = { id: fields[0], pass: fields[1], review: fields[2] };
    } else if (line.startsWith('@q ')) {
      const fields = line.slice(3).split('|').map(value => value.trim());
      assert.equal(fields.length, 15);
      practice.set(current.id, { ...current, prompt: fields[0], scenario: fields[1], options: fields.slice(2, 5),
        answer: Number(fields[5]), explanation: fields[6], wrong: fields.slice(7, 10),
        question: fields[10], hint: fields[11], correct: fields[12], soft: fields[13], sharp: fields[14] });
      current = undefined;
    }
  }
}
assert.equal(practice.size, 240);
assert.equal(expansion.reduce((sum, course) => sum + course.lessons.length, 0), 60);
const scores = { 'digital-life': 3 };
for (const lesson of existing[0].lessons) scores[lesson.id] = lesson.questions.length;
for (const lesson of expansion[0].lessons.slice(0, 9)) scores[lesson.id] = lesson.questions.length;
assert.equal(Object.keys(scores).length, 50);
const initial = { onboarded: true, name: 'Alex', darkMode: true, neonTheme: 'cyan', neonGlow: true,
  scores, lastLessonId: expansion[0].lessons[9].id, favoriteLessons: [existing[0].lessons[0].id],
  diagnosticScore: 4, heardDialogueIds: [], mistakeCounts: {} };
const escape = value => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const certifications = [
  ['Cisco CCST Networking', 'https://www.cisco.com/site/us/en/learn/training-certifications/certifications/support-technician/index.html'],
  ['Cisco CCST Cybersecurity', 'https://www.cisco.com/site/us/en/learn/training-certifications/certifications/support-technician/index.html'],
  ['ISC2 Certified in Cybersecurity (CC)', 'https://www.isc2.org/certifications/cc/cc-certification-exam-outline'],
  ['Cisco CCNA', 'https://www.cisco.com/site/us/en/learn/training-certifications/certifications/enterprise/ccna/index.html'],
];

(async () => {
  const browser = await chromium.launch({ headless: true,
    ...(process.env.AIOCYB_CHROMIUM ? { executablePath: process.env.AIOCYB_CHROMIUM } : {}) });
  const context = await browser.newContext({ viewport: { width: 1440, height: 1080 } });
  await context.grantPermissions(['clipboard-read', 'clipboard-write'], { origin: new URL(base).origin });
  const page = await context.newPage();
  let mobile = false, blocked = 0;
  const errors = [];
  const report = { version, viewports: ['1440x1080', '390x844', '320x740'],
    courses: [], reinforcementBanks: [], certifications: [], checks: [], screenshots: [], errors };
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => {
    if (/RenderFlex overflowed|A RenderFlex|OVERFLOWED BY/.test(message.text())) errors.push(message.text());
  });
  await page.route('**/*', route => {
    const url = route.request().url();
    if (url.startsWith('http') && new URL(url).origin !== new URL(base).origin) { blocked++; return route.abort(); }
    return route.continue();
  });
  await page.addInitScript(data => {
    if (!localStorage.getItem('aiocyb.academy.v1'))
      localStorage.setItem('aiocyb.academy.v1', JSON.stringify(JSON.stringify(data)));
  }, initial);
  const semantics = async () => {
    await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics[role="button"]'));
    const trigger = page.locator('flt-semantics-placeholder');
    if (await trigger.count()) await trigger.evaluate(element => element.click());
  };
  const expectText = text => page.waitForFunction(target => {
    const clean = value => value.replace(/\s+/g, ' ').trim();
    return [...document.querySelectorAll('flt-semantics,[aria-valuetext],input,textarea')].some(element =>
      clean((element.getAttribute('aria-label') || '') + (element.getAttribute('aria-valuetext') || '')
        + (element.innerText || '') + (element.value || '')).includes(clean(target)));
  }, text, { timeout: 15000 });
  const click = async (name, role = 'button') => {
    await page.getByRole(role, { name, exact: typeof name === 'string' }).first().click();
    await page.waitForTimeout(650);
  };
  const back = async () => {
    await page.getByRole('button', { name: /^(Atrás|Back|Volver)$/ }).evaluate(element => element.click());
    await page.waitForTimeout(650);
  };
  const nav = name => click(name, mobile ? 'tab' : 'button');
  const scrollTop = async () => {
    await page.mouse.move(mobile ? 170 : 900, 350); await page.mouse.wheel(0, -10000);
    await page.waitForTimeout(650);
  };
  const scrollBottom = async () => {
    await page.mouse.move(mobile ? 170 : 900, 450); await page.mouse.wheel(0, 15000);
    await page.waitForTimeout(650);
  };
  const capture = async name => {
    await page.mouse.move(5, 5); await page.waitForTimeout(1800);
    fs.mkdirSync(path.join(root, 'docs/screenshots', screenshotFolder), { recursive: true });
    const relative = path.join(screenshotFolder, name);
    await page.screenshot({ path: path.join(root, 'docs/screenshots', relative) });
    report.screenshots.push(relative.split(path.sep).join('/'));
  };
  const search = async value => {
    const input = page.getByRole('textbox').first();
    await input.click(); await page.waitForTimeout(250);
    await input.press('ControlOrMeta+A'); await input.press('Backspace'); await page.waitForTimeout(100);
    if (value) await input.pressSequentially(value, { delay: 50 });
    await page.waitForTimeout(650);
    await page.waitForFunction(text => [...document.querySelectorAll('input,textarea')]
      .some(element => element.value === text), value, { timeout: 5000 });
  };
  const saved = () => page.evaluate(() => JSON.parse(JSON.parse(localStorage.getItem('aiocyb.academy.v1'))));
  const answerPractice = async (question, option, dialogue) => {
    await click(question.options[option]); await click('Comprobar respuesta');
    await expectText(dialogue);
    await expectText(option === question.answer ? question.explanation : question.wrong[option]);
    await click('Ver mi resultado');
  };
  try {
    await page.goto(base, { waitUntil: 'networkidle' }); await semantics();
    await expectText('Hola, Alex');
    await click(/^Certificaciones/); await expectText('Guía de certificaciones');
    await capture('01-guia-certificaciones-escritorio.png');
    for (const [title, url] of certifications) {
      await click(new RegExp(`^${escape(title)}`));
      for (const text of ['Para quién sirve', 'Conocimientos previos', 'Qué trabajar',
        'Bases estudiadas en Aiocyb', 'Qué falta completar',
        'No mide preparación para el examen ni acredita una certificación.']) await expectText(text);
      if (title.startsWith('ISC2')) await expectText('1 de septiembre de 2026');
      await scrollBottom();
      await page.getByRole('button', { name: 'Copiar enlace oficial', exact: true })
        .nth(title.startsWith('ISC2') ? 1 : 0).click();
      await expectText('Enlace oficial copiado');
      assert.equal(await page.evaluate(() => navigator.clipboard.readText()), url);
      await scrollTop();
      if (title === 'Cisco CCST Networking') {
        await click(new RegExp(escape(existing[0].title))); await expectText('Tu curso');
        await back(); await expectText('Bases estudiadas en Aiocyb');
        await capture('02-meta-ccst-y-bases-locales.png');
      }
      report.certifications.push({ title, officialUrl: url, officialLinkCopied: true, localProgressIsNotCredential: true });
      await back();
    }
    await back(); await click(/^Mis rutas/); await expectText('6 rutas disponibles');
    await click(/Redes prácticas y ciberdefensa/); await expectText('6 cursos · 60 lecciones · 360 ejercicios');
    await capture('03-ruta-redes-y-ciberdefensa.png');
    for (const course of expansion) {
      await click(new RegExp(`Curso: ${escape(course.title)}`));
      await expectText('10 lecciones · 60 ejercicios');
      await click('Temario');
      const lesson = course.lessons[9];
      if (!await page.getByRole('button', { name: new RegExp(escape(lesson.title)) }).count())
        await click(/Módulo 3/);
      await click(new RegExp(escape(lesson.title))); await expectText(lesson.aoi.intro);
      await expectText('Supera la lección con 4 de 6 aciertos.');
      await click('Teoría', 'checkbox'); await expectText(lesson.sections[0].body);
      if (course.id === courseIds[0]) await capture('04-teoria-profunda-con-aoi.png');
      await click('Casos', 'checkbox'); await expectText(lesson.cases[0].explanation);
      await click('Siguiente'); await expectText(lesson.cases[1].explanation);
      if (course.id === courseIds[0]) {
        await click('Practicar · 6 ejercicios');
        for (const [index, question] of lesson.questions.entries()) {
          const answer = index < 4 ? question.answer : (question.answer + 1) % 3;
          await expectText(question.prompt); await click(question.options[answer]);
          await click('Comprobar respuesta');
          await expectText(answer === question.answer ? question.aoi.correct : question.aoi.soft);
          await click(index === 5 ? 'Ver mi resultado' : 'Siguiente ejercicio');
        }
        await expectText('4 / 6'); await expectText('¡Curso completado!');
        await expectText(course.closure.text); await capture('05-curso-completado-y-celebracion.png');
        await click('Volver a la lección');
        const state = await saved();
        assert.equal(state.scores[lesson.id], 4);
        for (const [id, score] of Object.entries(scores)) assert.equal(state.scores[id], score);
      }
      report.courses.push({ id: course.id, lessons: 10, exercises: 60,
        finalLessonOpened: lesson.id, theoryAndBothWorkedCases: true });
      await back(); await back();
    }
    await back(); await back();
    const resumeBeforePractice = (await saved()).lastLessonId;
    await nav('Cursos'); await click('Explorar catálogo');
    for (const [index, course] of existing.entries()) {
      await search(course.title); await click(new RegExp(escape(course.title)));
      await expectText('40 lecciones · 80 ejercicios');
      if (!index) await expectText('40 de 40 lecciones superadas');
      await click('Practicar refuerzos'); await expectText('0 de 40 refuerzos superados');
      assert.ok(await page.getByRole('button', { name: /40\. Refuerzo/ }).count());
      const original = course.lessons[index ? 39 : 0];
      const question = practice.get(original.id);
      await click(new RegExp(`${index ? '40' : '1'}\\. Refuerzo`));
      await expectText(question.question);
      if (!index) {
        await click('Dame una pista'); await expectText(question.hint);
        await answerPractice(question, (question.answer + 1) % 3, question.soft);
        await expectText(question.review);
        await click('Volver a practicar');
        await answerPractice(question, (question.answer + 1) % 3, question.sharp);
        await expectText('0 / 1');
        await click('Volver a practicar');
      }
      await answerPractice(question, question.answer, question.correct);
      await expectText('¡Refuerzo superado!'); await expectText(question.pass);
      await expectText('Esta práctica no cambia las aprobaciones ni añade XP de lección.');
      if (!index) await capture('06-refuerzo-superado-nota-independiente.png');
      await click('Volver a los refuerzos'); await expectText('1 de 40 refuerzos superados');
      report.reinforcementBanks.push({ course: course.id, questions: 40,
        exercisedId: `${original.id}-reinforcement`, preservedOriginalThresholds: true });
      await back(); await back();
    }
    const state = await saved();
    assert.equal(state.lastLessonId, resumeBeforePractice);
    assert.equal(state.mistakeCounts[`${existing[0].lessons[0].id}-reinforcement:0`], 2);
    for (const [id, score] of Object.entries(scores)) assert.equal(state.scores[id], score);
    assert.equal(Object.keys(state.scores).length, 57);
    await nav('Mi progreso'); await scrollTop();
    await expectText('51 de 490 lecciones superadas');
    await expectText('de 240 · nota independiente, sin XP de lección');
    await expectText('2550'); await capture('07-progreso-y-refuerzos-escritorio.png');
    await nav('Inicio'); await click(/^Repasar errores/);
    await expectText(practice.get(existing[0].lessons[0].id).prompt); await back();
    report.checks.push('All six new courses expose original theory, two worked cases and their final lesson',
      'Four correct answers of six pass the final lesson and complete its ten-lesson course',
      'All six existing network courses retain forty lessons and expose forty separate reinforcements',
      'First error is gentle; repeated error is sharper; hints, chosen-option explanations and result dialogue match the fixed context',
      'Six reinforcement passes add no lesson XP, preserve original best scores and leave the regular resume lesson unchanged',
      'The review list includes the independently graded reinforcement question',
      'Four certification guides distinguish local lessons from official exam preparation and external credentials');
    mobile = true; await page.setViewportSize({ width: 390, height: 844 });
    await nav('Inicio'); await scrollTop(); await capture('08-inicio-redes-android.png');
    await click(/^Certificaciones/); await capture('09-certificaciones-android.png'); await back();
    await nav('Ajustes'); await click(/Tema oscuro/, 'switch');
    await click('Neón violeta', 'checkbox'); await click(/Texto más grande/, 'switch');
    await page.setViewportSize({ width: 320, height: 740 });
    await nav('Inicio'); await click(/^Certificaciones/); await click(/^Cisco CCNA/);
    await expectText('No mide preparación para el examen ni acredita una certificación.');
    await capture('10-meta-ccna-clara-320.png'); await back(); await back();
    await nav('Mi progreso'); await scrollTop(); await capture('11-progreso-claro-320.png');
    await page.reload({ waitUntil: 'networkidle' }); await semantics();
    const restored = await saved();
    assert.deepEqual(restored.scores, state.scores);
    assert.equal(restored.diagnosticScore, 4);
    assert.deepEqual(restored.favoriteLessons, initial.favoriteLessons);
    assert.equal(restored.lastLessonId, resumeBeforePractice);
    assert.equal(restored.darkMode, false); assert.equal(restored.neonTheme, 'violet'); assert.equal(restored.largeText, true);
    for (const text of ['Otra explicación', 'Conversación guardada', 'Desactivar diálogos irónicos'])
      assert.equal(await page.getByRole('button', { name: text, exact: true }).count(), 0);
    assert.equal(errors.length, 0);
    report.checks.push('Grades, mistakes, diagnostic, favorites and resume state survive reload',
      'Certification and progress screens render at Android size and 320px light/violet with enlarged text',
      'Tutor dialogue controls and history remain unavailable; external HTTP is blocked throughout');
    const digest = file => createHash('sha256').update(fs.readFileSync(path.join(root, file))).digest('hex');
    report.compiledWebSha256 = digest('build/web/main.dart.js');
    report.sourceFiles = ['lib/src/data/network_expansion.g.dart', 'lib/src/data/network_practice.dart',
      'lib/src/data/network_sources.dart', 'lib/src/data/curriculum.dart', 'lib/src/data/certification_guides.dart',
      'lib/src/data/learning_paths.dart', 'lib/src/data/course_presentation.dart', 'lib/src/models/course.dart',
      'lib/src/models/learning_overview.dart', 'lib/src/state/academy_store.dart', 'lib/src/data/micro_lesson_dialogues.dart',
      'lib/src/screens/certifications.dart', 'lib/src/screens/practice_bank.dart', 'lib/src/screens/course_overview.dart',
      'lib/src/screens/lesson_studio.dart', 'lib/src/screens/explore_screens.dart', 'lib/src/screens/learning_home.dart',
      'lib/src/screens/learning_routes.dart', 'lib/src/screens/learning_progress.dart', 'pubspec.yaml']
      .map(file => ({ path: file, sha256: digest(file) }));
    report.regularPassedLessons = 51; report.completedReinforcements = 6; report.expectedXP = 2550;
    report.externalRequestsBlocked = blocked; report.status = 'passed';
    fs.writeFileSync(path.join(root, 'docs/NETWORK_BROWSER_AUDIT.json'), JSON.stringify(report, null, 2) + '\n');
    console.log(JSON.stringify(report, null, 2));
  } catch (error) {
    console.error(error);
    try {
      await page.screenshot({ path: path.join(root, 'build/network-ui-failure.png') });
      fs.writeFileSync(path.join(root, 'build/network-ui-semantics.txt'),
        (await page.locator('flt-semantics').allTextContents()).join('\n'));
    } catch (_) {}
    process.exitCode = 1;
  } finally { await browser.close(); }
})();
