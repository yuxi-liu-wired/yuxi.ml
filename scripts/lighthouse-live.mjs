#!/usr/bin/env node
// Run Lighthouse against live yuxi.ml
import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';

const CHROME_PATH = '/home/node/.cache/ms-playwright/chromium-1208/chrome-linux64/chrome';

const PAGES = [
  { name: 'Home', url: 'https://yuxi.ml/' },
  { name: '/cyc', url: 'https://yuxi.ml/cyc' },
  { name: '/essays', url: 'https://yuxi.ml/essays' },
];

for (const page of PAGES) {
  const chrome = await chromeLauncher.launch({
    chromePath: CHROME_PATH,
    chromeFlags: ['--headless=new', '--no-sandbox', '--disable-gpu', '--disable-dev-shm-usage'],
  });

  try {
    console.log(`━━━ ${page.name} (${page.url}) ━━━`);
    const result = await lighthouse(page.url, {
      port: chrome.port,
      output: 'json',
      onlyCategories: ['performance', 'accessibility', 'best-practices', 'seo'],
    });

    const { categories, audits } = result.lhr;
    for (const [key, cat] of Object.entries(categories)) {
      const score = Math.round(cat.score * 100);
      const bar = score >= 90 ? '🟢' : score >= 50 ? '🟠' : '🔴';
      console.log(`  ${bar} ${cat.title}: ${score}`);
    }

    // Show failed audits sorted by weight
    const failed = [];
    for (const [key, cat] of Object.entries(categories)) {
      for (const ref of cat.auditRefs) {
        const audit = audits[ref.id];
        if (audit && audit.score !== null && audit.score < 1 && ref.weight > 0) {
          failed.push({
            category: cat.title,
            id: ref.id,
            title: audit.title,
            score: audit.score,
            weight: ref.weight,
            displayValue: audit.displayValue || '',
          });
        }
      }
    }
    failed.sort((a, b) => b.weight - a.weight);
    if (failed.length > 0) {
      console.log(`\n  Failed audits (by weight):`);
      for (const f of failed) {
        const s = Math.round(f.score * 100);
        console.log(`    [${f.category}] w=${f.weight} ${f.title} (${s}) ${f.displayValue}`);
      }
    }

    // Show top network payloads
    const payloads = audits['total-byte-weight'];
    if (payloads?.details?.items?.length) {
      console.log(`\n  Largest resources:`);
      for (const item of payloads.details.items.slice(0, 5)) {
        console.log(`    ${Math.round(item.totalBytes / 1024)}KB  ${item.url}`);
      }
    }
    console.log('');
  } finally {
    await chrome.kill();
  }
}
