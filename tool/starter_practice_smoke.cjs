// Optional browser smoke test. Requires a web build served at AIOCYB_PREVIEW_URL
// and Playwright (AIOCYB_PLAYWRIGHT can point to an external installation).
const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const { chromium } = require(process.env.AIOCYB_PLAYWRIGHT || 'playwright');
const base = process.env.AIOCYB_PREVIEW_URL || 'http://127.0.0.1:8893';
const root = path.resolve(__dirname, '..');
const originalIds = ['digital-life', 'risk-routine', 'passwords', 'mfa', 'phishing-signals', 'safe-response'];

(async () => {
  const browser = await chromium.launch({
    headless: true,
    ...(process.env.AIOCYB_CHROMIUM ? { executablePath: process.env.AIOCYB_CHROMIUM } : {}),
  });
  const report = [];
  try {
    for (const courseId of ['foundations', 'identity', 'phishing']) {
      const source = JSON.parse(fs.readFileSync(path.join(root, 'assets/practice', courseId + '.json'), 'utf8'));
      const lesson = source.lessons[0];
      const context = await browser.newContext({ viewport: { width: 390, height: 844 } });
      try {
        const page = await context.newPage();
        const errors = [];
        let blocked = 0;
        page.on('pageerror', e => errors.push(e.message));
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
        }, {
          onboarded: true, name: 'Alex', darkMode: true, lastLessonId: lesson.id,
          scores: Object.fromEntries(originalIds.map(id => [id, 3])),
          heardDialogueIds: [], mistakeCounts: {},
        });
        const saved = () => page.evaluate(() => JSON.parse(JSON.parse(localStorage.getItem('aiocyb.academy.v1'))));
        const hasText = text => page.locator('flt-semantics').evaluateAll(
          (elements, target) => elements.some(e => ((e.getAttribute('aria-label') || '') + e.innerText).includes(target)), text,
        );
        const expectText = async (text, message) => {
          await page.waitForFunction(target =>
            Array.from(document.querySelectorAll('flt-semantics')).some(e =>
              ((e.getAttribute('aria-label') || '') + e.innerText).includes(target)),
            text, { timeout: 10000 },
          );
          assert(await hasText(text), message);
        };
        const click = async name => {
          await page.getByRole('button', { name, exact: true }).click();
          await page.waitForTimeout(100);
        };
        const noControls = async () => {
          for (const name of ['Otra explicación', 'Conversación guardada', 'Releer explicaciones vistas']) {
            assert.equal(await page.getByRole('button', { name, exact: true }).count(), 0);
          }
        };
        await page.goto(base, { waitUntil: 'networkidle' });
        await page.locator('flt-semantics-placeholder').evaluate(e => e.click());
        await click('Continuar aprendiendo');
        await page.getByRole('checkbox', { name: 'Teoría', exact: true }).click();
        await expectText(lesson.sections[0].body, 'Missing lesson theory');
        await expectText(lesson.aoi.theory, 'Wrong theory script');
        if (courseId === 'foundations') {
          await page.screenshot({ path: path.join(root, 'docs/screenshots/16-refuerzo-teoria.png') });
        }
        await click('Practicar · 3 ejercicios');
        const attempts = courseId === 'foundations' ? 2 : 1;
        for (let attempt = 0; attempt < attempts; attempt++) {
          for (let index = 0; index < lesson.questions.length; index++) {
            const q = lesson.questions[index];
            await expectText(q.scenario, 'Missing question case');
            await expectText(q.aoi.question, 'Wrong Aoi introduction');
            assert(!(await hasText(q.explanation)), 'Answer reasoning shown before checking');
            await noControls();
            if (courseId === 'foundations' && attempt === 0 && index === 0) {
              await page.screenshot({ path: path.join(root, 'docs/screenshots/17-refuerzo-caso-individual.png') });
            }
            if (index > 0) assert(!(await hasText(lesson.questions[index - 1].scenario)), 'Stale previous case');
            await click('Dame una pista');
            await expectText(q.aoi.hint, 'Wrong question hint');
            const choice = index === 0 ? (q.answer + 1) % 3 : q.answer;
            await click(q.options[choice]);
            await click('Comprobar respuesta');
            await expectText(q.aoi[index === 0 ? (attempt ? 'sharp' : 'soft') : 'correct'], 'Wrong reaction');
            await expectText(index === 0 ? q.wrongExplanations[choice] : q.explanation, 'Wrong feedback');
            await click(index === 2 ? 'Ver mi resultado' : 'Siguiente ejercicio');
          }
          await expectText('2 / 3', 'Wrong result');
          if (attempt < attempts - 1) await click('Volver a practicar');
        }
        if (courseId === 'foundations') {
          await page.screenshot({ path: path.join(root, 'docs/screenshots/18-refuerzo-resultado.png') });
        }
        await page.reload({ waitUntil: 'networkidle' });
        const data = await saved();
        assert.equal(data.scores[lesson.id], 2);
        assert.equal(data.mistakeCounts[lesson.id + ':0'], attempts);
        for (const id of originalIds) assert.equal(data.scores[id], 3, 'Original grade lost');
        assert.deepEqual(errors, []);
        report.push({ courseId, score: 2, questions: 3, mistakeCount: attempts, originalGradesRetained: 6, independentCases: true, dialogueControls: false, persistedAfterReload: true, blockedExternalRequests: blocked, errors });
      } finally {
        await context.close();
      }
    }
    console.log(JSON.stringify(report, null, 2));
    fs.writeFileSync(path.join(root, 'docs/STARTER_BROWSER_AUDIT.json'), JSON.stringify(report, null, 2) + '\n');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
