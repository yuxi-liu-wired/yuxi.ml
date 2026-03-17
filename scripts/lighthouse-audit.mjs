#!/usr/bin/env node
// Run Lighthouse audits against local nginx and output summary.
import { readdirSync } from 'fs';
import { join } from 'path';
import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';

const PW_DIR = join(process.env.HOME, '.cache', 'ms-playwright');
const chromium = readdirSync(PW_DIR).filter(d => d.startsWith('chromium-')).sort().pop();
if (!chromium) throw new Error('No Chromium found in ' + PW_DIR);
const CHROME_PATH = join(PW_DIR, chromium, 'chrome-linux64', 'chrome');

const PAGES = [
  { name: 'Home', url: 'http://localhost:8080/' },
  { name: '/cyc', url: 'http://localhost:8080/cyc' },
  { name: '/essays', url: 'http://localhost:8080/essays' },
];

const chrome = await chromeLauncher.launch({
  chromePath: CHROME_PATH,
  chromeFlags: ['--headless', '--no-sandbox', '--disable-gpu'],
});

console.log(`Chrome running on port ${chrome.port}\n`);

for (const page of PAGES) {
  console.log(`━━━ ${page.name} (${page.url}) ━━━`);
  const result = await lighthouse(page.url, {
    port: chrome.port,
    output: 'json',
    onlyCategories: ['performance', 'accessibility', 'best-practices', 'seo'],
  });
  const { categories } = result.lhr;
  for (const [key, cat] of Object.entries(categories)) {
    const score = Math.round(cat.score * 100);
    const bar = score >= 90 ? '🟢' : score >= 50 ? '🟠' : '🔴';
    console.log(`  ${bar} ${cat.title}: ${score}`);
  }

  // Show failed audits (score < 1) grouped by category
  const audits = result.lhr.audits;
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
  // Sort by weight descending (highest impact first)
  failed.sort((a, b) => b.weight - a.weight);
  if (failed.length > 0) {
    console.log(`\n  Failed audits (sorted by weight):`);
    for (const f of failed) {
      const s = Math.round(f.score * 100);
      console.log(`    [${f.category}] w=${f.weight} ${f.title} (${s}) ${f.displayValue}`);
    }
  }
  console.log('');
}

await chrome.kill();
