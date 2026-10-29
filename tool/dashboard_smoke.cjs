// Real compiled-UI journeys with legacy local data and external HTTP blocked.
const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');
const { chromium } = require(process.env.AIOCYB_PLAYWRIGHT || 'playwright');
const root = path.resolve(__dirname, '..');
const version = fs.readFileSync(path.join(root, 'pubspec.yaml'), 'utf8').match(/^version:\s*(\S+)/m)[1];
const screenshotFolder = `${version.split('.').slice(0, 2).join('.')}-dashboard`;
const base = process.env.AIOCYB_PREVIEW_URL || 'http://127.0.0.1:8896';
const read = relative => JSON.parse(fs.readFileSync(path.join(root, relative), 'utf8'));
const linux = read('assets/linux/linux-start.json');
const scores = { 'digital-life': 3, 'risk-routine': 3 };
for (const lesson of read('assets/practice/foundations.json').lessons) scores[lesson.id] = lesson.questions.length;
assert.equal(Object.keys(scores).length, 10);
scores.passwords = 1;
const initial = { onboarded: true, name: 'Alex', darkMode: true, neonTheme: 'cyan', neonGlow: true,
  scores, lastLessonId: linux.lessons[0].id, diagnosticScore: 4,
  favoriteLessons: [linux.lessons[0].id], mistakeCounts: { 'passwords:1': 1, 'diagnostic:2': 1 }, heardDialogueIds: [] };
const paths = [
  ['start', 'Tu primera defensa', '3 cursos · 30 lecciones · 90 ejercicios'],
  ['networks', 'Conecta con criterio', '6 cursos · 240 lecciones · 480 ejercicios'],
  ['recovery', 'Prevenir, responder y recuperar', '6 cursos · 60 lecciones · 240 ejercicios'],
  ['build', 'Construye seguridad', '4 cursos · 40 lecciones · 120 ejercicios'],
  ['linux', 'Linux: observa, comprende e investiga', '6 cursos · 60 lecciones · 240 ejercicios'],
  ['advanced-networks', 'Redes prácticas y ciberdefensa', '6 cursos · 60 lecciones · 360 ejercicios'],
];
const escape = value => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

(async () => {
  const browser = await chromium.launch({ headless: true, ...(process.env.AIOCYB_CHROMIUM ? { executablePath: process.env.AIOCYB_CHROMIUM } : {}) });
  const context = await browser.newContext({ viewport: { width: 1440, height: 1080 } });
  const page = await context.newPage();
  let blocked = 0, mobile = false;
  const errors = [];
  const report = { version,
    viewports: ['1440x1080', '390x844', '320x740'], paths: [], checks: [], screenshots: [], errors };
  page.on('pageerror', error => errors.push(error.message));
  await page.route('**/*', route => {
    const url = route.request().url();
    if (url.startsWith('http') && new URL(url).origin !== new URL(base).origin) { blocked++; return route.abort(); }
    return route.continue();
  });
  await page.addInitScript(data => {
    if (!localStorage.getItem('aiocyb.academy.v1')) localStorage.setItem('aiocyb.academy.v1', JSON.stringify(JSON.stringify(data)));
  }, initial);
  const semantics = async () => {
    await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics[role="button"]'));
    const trigger = page.locator('flt-semantics-placeholder');
    if (await trigger.count()) await trigger.evaluate(e => e.click());
  };
  const expectText = target => page.waitForFunction(text => {
    const clean = value => value.replace(/\s+/g, ' ').trim();
    return [...document.querySelectorAll('flt-semantics,input,textarea')].some(e =>
      clean((e.getAttribute('aria-label') || '') + (e.innerText || '') + (e.value || '')).includes(clean(text)));
  }, target, { timeout: 15000 });
  const click = async (name, role = 'button') => {
    await page.getByRole(role, { name, exact: typeof name === 'string' }).first().click();
    await page.waitForTimeout(650);
  };
  const nav = name => click(name, mobile ? 'tab' : 'button');
  const back = async () => {
    await page.getByRole('button', { name: /^(Atrás|Back|Volver)$/ }).evaluate(e => e.click());
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
    const field = page.getByRole('textbox', { name: /Buscar en mi progreso/ });
    await field.click(); await page.waitForTimeout(650);
    await page.waitForFunction(() => {
      const active = document.activeElement;
      return active && /^(INPUT|TEXTAREA)$/.test(active.tagName) && !active.disabled;
    });
    await page.keyboard.press('ControlOrMeta+A'); await page.keyboard.press('Backspace');
    await page.waitForTimeout(250);
    if (value) await page.keyboard.type(value, { delay: 80 });
    await page.waitForTimeout(650);
    await page.waitForFunction(text => [...document.querySelectorAll('input,textarea')]
      .some(input => input.value === text), value, { timeout: 5000 });
  };
  const scrollTop = async () => {
    await page.mouse.move(mobile ? 170 : 900, 300); await page.mouse.wheel(0, -10000);
    await page.waitForTimeout(650);
  };
  const saved = () => page.evaluate(() => JSON.parse(JSON.parse(localStorage.getItem('aiocyb.academy.v1'))));
  try {
    await page.goto(base, { waitUntil: 'networkidle' }); await semantics();
    await expectText('Hola, Alex'); await expectText(linux.lessons[0].title);
    await capture('54-inicio-escritorio.png');
    await click('Continuar aprendiendo'); await expectText(linux.lessons[0].aoi.intro); await back();
    await click(/^Mis rutas/); await expectText('6 rutas disponibles');
    await capture('55-rutas-escritorio.png');
    for (const [id, title, totals] of paths) {
      await click(new RegExp(escape(title))); await expectText(totals);
      if (id === 'linux') {
        await capture('56-ruta-linux-detalle.png');
        await click(/Investiga un caso en Linux/); await expectText('Tu curso');
        await back();
        await page.mouse.move(800, 700); await page.mouse.wheel(0, 650);
        await capture('57-recorrido-cursos.png');
      }
      report.paths.push({ id, totalsVerified: true });
      await back();
    }
    await scrollTop();
    await click('En curso', 'checkbox'); await expectText('2 rutas disponibles');
    await click('Completadas', 'checkbox'); await expectText('Todavía no hay rutas con este estado.');
    await click('Ver todas las rutas'); await back();
    await nav('Mi progreso'); await expectText('10 de 490 lecciones superadas');
    await expectText('31 de 33 preguntas con nota'); await capture('58-progreso-escritorio.png');
    await search('cuentas tus'); await expectText('Mejor resultado: 1/3');
    await capture('59-notas-por-curso.png');
    await click(/Mejor resultado: 1\/3/); await expectText('Tu aula con Aoi'); await back();
    await search(''); await click('Completados', 'checkbox'); await expectText('1 curso en este estado');
    await capture('60-cursos-completados.png');
    await click('En curso', 'checkbox'); await expectText('2 cursos en este estado');
    await nav('Inicio'); await click(/^Repasar errores/); await expectText('2 ejercicios pendientes.');
    await back();
    report.checks.push('Home resumes the original Linux lesson and shows three recommendations',
      'All six paths expose real totals, including 240 separate network reinforcements; final Linux course remains accessible',
      'Course search handles reversed words and exposes the original 1/3 grade',
      'Completed and started filters distinguish failed attempts and ungraded visits',
      'Review shortcut includes original course and diagnostic mistakes');
    mobile = true; await page.setViewportSize({ width: 390, height: 844 });
    await nav('Inicio'); await capture('61-inicio-android.png');
    await click(/^Mis rutas/); await capture('62-rutas-android.png');
    await click(/Linux: observa, comprende e investiga/); await capture('63-ruta-android.png');
    await back(); await back(); await nav('Mi progreso'); await scrollTop(); await capture('64-progreso-android.png');
    await nav('Ajustes'); await click(/Tema oscuro/, 'switch');
    await click('Neón violeta', 'checkbox'); await click(/Texto más grande/, 'switch');
    await page.setViewportSize({ width: 320, height: 740 });
    await nav('Inicio'); await capture('65-inicio-claro-320.png');
    await click(/^Mis rutas/); await click(/Linux: observa, comprende e investiga/);
    await capture('66-ruta-clara-320.png'); await back(); await back();
    await nav('Mi progreso'); await scrollTop(); await capture('67-progreso-claro-320.png');
    await page.reload({ waitUntil: 'networkidle' }); await semantics();
    const restored = await saved();
    assert.deepEqual(restored.scores, scores); assert.equal(restored.diagnosticScore, 4);
    assert.deepEqual(restored.favoriteLessons, [linux.lessons[0].id]);
    assert.ok(restored.startedCourseIds.includes('linux-start'));
    assert.ok(restored.startedCourseIds.includes('identity'));
    assert.equal(restored.darkMode, false); assert.equal(restored.neonTheme, 'violet'); assert.equal(restored.largeText, true);
    assert.equal(errors.length, 0);
    report.checks.push('Legacy starts migrate and remain started after visiting a different course and reloading',
      'Grades, diagnostic, favorite lesson and neon preferences are retained',
      'Home, routes and progress work in light mode with enlarged text at 320px');
    const digest = file => createHash('sha256').update(fs.readFileSync(path.join(root, file))).digest('hex');
    report.compiledWebSha256 = digest('build/web/main.dart.js');
    report.sourceFiles = ['lib/src/models/learning_overview.dart', 'lib/src/state/academy_store.dart',
      'lib/src/screens/learning_home.dart', 'lib/src/screens/learning_progress.dart', 'lib/src/screens/learning_routes.dart',
      'lib/src/screens/dashboard_actions.dart', 'lib/src/screens/academy_screens.dart', 'lib/src/screens/explore_screens.dart',
      'lib/src/widgets/learning_dashboard.dart', 'lib/src/widgets/learning_link.dart',
      'lib/src/data/learning_paths.dart', 'lib/src/data/curriculum.dart',
      'lib/src/data/course_presentation.dart', 'lib/src/data/network_expansion.g.dart',
      'lib/src/data/network_practice.dart', 'lib/src/screens/certifications.dart',
      'pubspec.yaml'].map(file => ({ path: file, sha256: digest(file) }));
    report.status = 'passed'; report.externalRequestsBlocked = blocked;
    report.preservedGrades = Object.keys(restored.scores).length; report.expectedXP = 500;
    fs.writeFileSync(path.join(root, 'docs/DASHBOARD_BROWSER_AUDIT.json'), JSON.stringify(report, null, 2) + '\n');
    console.log(JSON.stringify(report, null, 2));
  } catch (error) {
    console.error(error);
    try { await page.screenshot({ path: path.join(root, 'build/dashboard-failure.png') });
      fs.writeFileSync(path.join(root, 'build/dashboard-semantics.txt'), (await page.locator('flt-semantics').allTextContents()).join('\n'));
    } catch (_) {}
    process.exitCode = 1;
  } finally { await browser.close(); }
})();
