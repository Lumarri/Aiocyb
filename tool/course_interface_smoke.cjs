// Verify the compiled course platform, retaining local grades and blocking CDN access.
const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');
const { chromium } = require(process.env.AIOCYB_PLAYWRIGHT || 'playwright');
const root = path.resolve(__dirname, '..');
const version = fs.readFileSync(path.join(root, 'pubspec.yaml'), 'utf8').match(/^version:\s*(\S+)/m)[1];
const screenshotFolder = version.startsWith('1.5.') ? '' : '1.6-courses';
const base = process.env.AIOCYB_PREVIEW_URL || 'http://127.0.0.1:8895';
const linux = JSON.parse(fs.readFileSync(path.join(root, 'assets/linux/linux-start.json'), 'utf8'));
const escape = text => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

(async () => {
  const browser = await chromium.launch({ headless: true, ...(process.env.AIOCYB_CHROMIUM ? { executablePath: process.env.AIOCYB_CHROMIUM } : {}) });
  const context = await browser.newContext({ viewport: { width: 1440, height: 1080 } });
  const page = await context.newPage();
  let blocked = 0;
  const errors = [], assets = new Set();
  const report = { version, viewports: ['1440x1080', '390x844', '320x740'], screenshots: [], checks: [], errors };
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => {
    if (response.url().includes('/assets/artwork/') && response.ok()) assets.add(response.url().split('/').pop());
  });
  await page.route('**/*', route => {
    const url = route.request().url();
    if (url.startsWith('http') && new URL(url).origin !== new URL(base).origin) { blocked++; return route.abort(); }
    return route.continue();
  });
  await page.addInitScript(() => {
    if (!localStorage.getItem('aiocyb.academy.v1')) localStorage.setItem('aiocyb.academy.v1', JSON.stringify(JSON.stringify({
      onboarded: true, name: 'Alex', darkMode: true, neonTheme: 'cyan', neonGlow: true,
      scores: { 'digital-life': 3 }, lastLessonId: 'risk-routine', heardDialogueIds: [], mistakeCounts: {},
    })));
  });
  const expectText = text => page.waitForFunction(target => {
    const clean = value => value.replace(/\s+/g, ' ').trim();
    return [...document.querySelectorAll('flt-semantics,input,textarea')].some(e =>
      clean((e.getAttribute('aria-label') || '') + (e.innerText || '') + (e.value || '')).includes(clean(target)));
  }, text, { timeout: 15000 });
  const click = async (name, role = 'button') => {
    await page.getByRole(role, { name, exact: typeof name === 'string' }).first().click();
    await page.waitForTimeout(650);
  };
  const back = async () => {
    await page.getByRole('button', { name: /^(Atrás|Back|Volver)$/ }).evaluate(e => e.click());
    await page.waitForTimeout(650);
  };
  const capture = async name => {
    await page.mouse.move(5, 5); await page.waitForTimeout(2200);
    const relative = path.join(screenshotFolder, name);
    fs.mkdirSync(path.join(root, 'docs/screenshots', screenshotFolder), { recursive: true });
    await page.screenshot({ path: path.join(root, 'docs/screenshots', relative) });
    report.screenshots.push(relative.split(path.sep).join('/'));
  };
  const search = async text => {
    const input = page.getByRole('textbox').first();
    await input.click(); await input.press('ControlOrMeta+A');
    await input.press('Backspace'); await input.pressSequentially(text, { delay: 35 });
    await page.waitForTimeout(650);
  };
  const enableSemantics = async () => {
    await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics[role="button"]'));
    const trigger = page.locator('flt-semantics-placeholder');
    if (await trigger.count()) await trigger.evaluate(e => e.click());
  };
  try {
    await page.goto(base, { waitUntil: 'networkidle' }); await enableSemantics();
    await click('Cursos'); await expectText('Encuentra tu próximo curso');
    await capture('42-catalogo-escritorio.png');
    await click('Explorar catálogo'); await capture('43-biblioteca-cursos.png');
    await search('linux'); await expectText('6 cursos disponibles');
    await capture('44-cursos-linux-escritorio.png');
    await click(new RegExp(escape(linux.title))); await expectText('Lo que vas a aprender');
    await capture('45-presentacion-curso.png');
    await click('Temario'); await expectText('Contenido del curso');
    await capture('46-modulos-curso.png');
    await click('Conceptos'); await expectText('Conceptos clave');
    await click(/Leer concepto/); await expectText(linux.lessons[0].sections[0].body);
    await capture('47-lector-conceptos.png');
    await click('Estudiar esta lección'); await expectText(linux.lessons[0].aoi.intro);
    await page.getByRole('checkbox', { name: 'Teoría', exact: true }).click();
    await expectText(linux.lessons[0].sections[0].body);
    await capture('48-aula-escritorio.png');
    await click('Temario del curso');
    await click(new RegExp(escape(linux.lessons[9].title))); await expectText(linux.lessons[9].aoi.intro);
    await back(); await expectText('Tu curso');
    report.checks.push('Concept previews use original theory and open the matching lesson',
      'In-class syllabus replaces the lesson and Back returns directly to the course');
    await back(); await search('');
    await page.setViewportSize({ width: 390, height: 844 });
    await page.waitForTimeout(500);
    await click('Cursos', 'tab'); await click('Explorar catálogo');
    await capture('49-catalogo-android.png');
    await search('pesquen'); await expectText('1 curso disponible');
    await click(/Que no te pesquen/); await capture('50-curso-android.png');
    await click('Temario'); await capture('51-temario-android.png');
    await back(); await search('criptografia'); await expectText('4 cursos disponibles');
    await search('esto-no-existe'); await expectText('No encontramos cursos con esa búsqueda.');
    await click('Ver todos los cursos'); await expectText('25 cursos disponibles');
    report.checks.push('Accent-insensitive search, empty results and reset work on Android-sized layout');
    await click('Ajustes', 'tab'); await click(/Tema oscuro/, 'switch');
    await click('Neón violeta', 'checkbox');
    await click(/Texto más grande/, 'switch');
    await page.setViewportSize({ width: 320, height: 740 });
    await click('Cursos', 'tab'); await click('Explorar catálogo');
    await capture('52-catalogo-claro-320.png');
    await search('linux'); await click(new RegExp(escape(linux.title)));
    await click('Conceptos'); await click(/Leer concepto/);
    await expectText(linux.lessons[0].sections[0].body); await capture('53-concepto-claro-320.png');
    await click('Cerrar concepto'); await back();
    await page.reload({ waitUntil: 'networkidle' }); await enableSemantics();
    const saved = await page.evaluate(() => JSON.parse(JSON.parse(localStorage.getItem('aiocyb.academy.v1'))));
    assert.equal(saved.scores['digital-life'], 3);
    assert.equal(saved.darkMode, false); assert.equal(saved.neonTheme, 'violet'); assert.equal(saved.largeText, true);
    assert.equal(assets.size, 5); assert.equal(errors.length, 0);
    report.checks.push('Original grade retained across navigation and reload',
      'Light/violet theme and large text persist at 320px', 'All five original covers loaded from local assets');
    for (const text of ['Otra explicación', 'Conversación guardada', 'Desactivar diálogos irónicos'])
      assert.equal(await page.getByRole('button', { name: text, exact: true }).count(), 0);
    const digest = relative => createHash('sha256').update(fs.readFileSync(path.join(root, relative))).digest('hex');
    report.compiledWebSha256 = digest('build/web/main.dart.js');
    report.sourceFiles = ['lib/src/data/course_presentation.dart', 'lib/src/screens/course_catalog.dart',
      'lib/src/screens/course_overview.dart', 'lib/src/screens/lesson_studio.dart',
      'lib/src/screens/lesson_navigation.dart', 'lib/src/widgets/course_visuals.dart',
      'lib/src/widgets/common.dart', 'lib/src/models/learning_overview.dart',
      'lib/src/screens/academy_screens.dart', 'lib/src/screens/learning_home.dart',
      'lib/src/screens/learning_routes.dart', 'lib/src/screens/learning_progress.dart',
      'lib/src/widgets/learning_dashboard.dart', 'lib/src/widgets/learning_link.dart',
      'lib/src/state/academy_store.dart', 'pubspec.yaml'].map(file => ({ path: file, sha256: digest(file) }));
    report.localCovers = [...assets].sort(); report.externalRequestsBlocked = blocked; report.status = 'passed';
    fs.writeFileSync(path.join(root, 'docs/COURSE_BROWSER_AUDIT.json'), JSON.stringify(report, null, 2) + '\n');
    console.log(JSON.stringify(report, null, 2));
  } catch (error) {
    console.error(error);
    try { await page.screenshot({ path: path.join(root, 'build/course-ui-failure.png') });
      fs.writeFileSync(path.join(root, 'build/course-ui-semantics.txt'), await page.locator('flt-semantics').allTextContents().then(a => a.join('\n')));
    } catch (_) {}
    process.exitCode = 1;
  } finally { await browser.close(); }
})();
