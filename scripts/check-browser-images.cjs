#!/usr/bin/env node
// Check every page in a real browser for broken images.
// Usage: node scripts/check-browser-images.cjs [BASE_URL]
const { chromium } = require('playwright');

const BASE = process.argv[2] || 'http://localhost:8080';

(async () => {
  const browser = await chromium.launch({ args: ['--no-sandbox'] });

  // Get pages from sitemap
  const page = await browser.newPage();
  const res = await page.goto(`${BASE}/sitemap.xml`);
  const xml = await res.text();
  const urls = [...xml.matchAll(/<loc>([^<]+)<\/loc>/g)]
    .map(m => m[1].replace('https://yuxi.ml', BASE));

  console.log(`Checking ${urls.length} pages...\n`);

  let totalBroken = 0;
  const brokenPages = [];

  for (const url of urls) {
    try {
      await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
    } catch {
      continue;
    }

    const results = await page.evaluate(() =>
      Array.from(document.querySelectorAll('img')).map(img => ({
        src: img.getAttribute('src'),
        resolved: img.src,
        broken: img.complete && img.naturalWidth === 0,
      }))
    );

    const broken = results.filter(r => r.broken);
    if (broken.length > 0) {
      const shortUrl = url.replace(BASE, '');
      console.log(`${shortUrl}  (${broken.length} broken)`);
      for (const b of broken) {
        console.log(`  ${b.src}  →  ${b.resolved}`);
      }
      totalBroken += broken.length;
      brokenPages.push(shortUrl);
    }
  }

  console.log(`\n${totalBroken} broken images across ${brokenPages.length} pages`);
  await browser.close();
  process.exit(totalBroken > 0 ? 1 : 0);
})();
