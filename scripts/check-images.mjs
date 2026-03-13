#!/usr/bin/env node
// Check every <img> on every page — resolve URLs as a browser would, fetch with
// browser-like Accept headers, verify status + content type.
// Usage: node scripts/check-images.mjs [BASE_URL]

const BASE = process.argv[2] || 'http://localhost:8080';

async function fetchText(url) {
  const res = await fetch(url, { redirect: 'follow' });
  if (!res.ok) return null;
  return res.text();
}

// Get all pages
const sitemapOrCrawl = async () => {
  const pages = [];
  // Find all index.html files by fetching sitemap or crawling
  const sitemap = await fetchText(`${BASE}/sitemap.xml`);
  if (sitemap) {
    for (const m of sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)) {
      pages.push(m[1].replace('https://yuxi.ml', BASE));
    }
  }
  return pages;
};

const pages = await sitemapOrCrawl();
console.log(`Found ${pages.length} pages\n`);

let totalImages = 0;
let broken = 0;
const seen = new Set();

for (const pageUrl of pages) {
  const html = await fetchText(pageUrl);
  if (!html) continue;

  // Extract all img src attributes (handle both quote styles)
  const imgSrcs = [];
  for (const m of html.matchAll(/<img[^>]+src="([^"]+)"/gi)) {
    imgSrcs.push(m[1]);
  }
  for (const m of html.matchAll(/<img[^>]+src='([^']+)'/gi)) {
    imgSrcs.push(m[1]);
  }
  if (imgSrcs.length === 0) continue;

  // Resolve relative URLs as browser would
  for (const src of imgSrcs) {
    let resolved;
    try {
      resolved = new URL(src, pageUrl).href;
    } catch {
      continue;
    }

    // Only check local images
    if (!resolved.startsWith(BASE)) continue;
    if (seen.has(resolved)) continue;
    seen.add(resolved);
    totalImages++;

    // Fetch with browser-like Accept header
    try {
      const res = await fetch(resolved, {
        headers: { 'Accept': 'image/avif,image/webp,image/png,image/jpeg,*/*' },
        redirect: 'follow',
      });
      const ct = res.headers.get('content-type') || '';
      const size = parseInt(res.headers.get('content-length') || '0');

      if (!res.ok) {
        console.log(`BROKEN ${res.status}  ${resolved}`);
        console.log(`  from: ${pageUrl}`);
        broken++;
      } else if (!ct.startsWith('image/') && !ct.includes('octet-stream')) {
        console.log(`WRONG-TYPE ${ct}  ${resolved}`);
        console.log(`  from: ${pageUrl}`);
        broken++;
      }
    } catch (err) {
      console.log(`ERROR ${err.message}  ${resolved}`);
      console.log(`  from: ${pageUrl}`);
      broken++;
    }
  }
}

console.log(`\n${totalImages} unique images checked, ${broken} broken`);
process.exit(broken > 0 ? 1 : 0);
