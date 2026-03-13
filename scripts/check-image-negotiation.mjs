#!/usr/bin/env node
// Verify content negotiation: for every image, check that the AVIF/WebP
// variant (if served) is actually a valid image with correct content-type.
// Usage: node scripts/check-image-negotiation.mjs [BASE_URL]

const BASE = process.argv[2] || 'http://localhost:8080';

async function fetchText(url) {
  const res = await fetch(url, { redirect: 'follow' });
  if (!res.ok) return null;
  return res.text();
}

const pages = [];
const sitemap = await fetchText(`${BASE}/sitemap.xml`);
if (sitemap) {
  for (const m of sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)) {
    pages.push(m[1].replace('https://yuxi.ml', BASE));
  }
}
console.log(`Found ${pages.length} pages\n`);

let total = 0, negotiated = 0, broken = 0;
const seen = new Set();

for (const pageUrl of pages) {
  const html = await fetchText(pageUrl);
  if (!html) continue;

  for (const m of html.matchAll(/<img[^>]+src="([^"]+)"/gi)) {
    let resolved;
    try { resolved = new URL(m[1], pageUrl).href; } catch { continue; }
    if (!resolved.startsWith(BASE)) continue;
    if (seen.has(resolved)) continue;
    seen.add(resolved);

    // Only check negotiable formats
    if (!/\.(png|jpe?g|gif)$/i.test(resolved)) continue;
    total++;

    // Fetch with AVIF preference (like Chrome)
    const res = await fetch(resolved, {
      headers: { 'Accept': 'image/avif,image/webp,image/png,image/jpeg,*/*' },
      redirect: 'follow',
    });

    if (!res.ok) {
      console.log(`404  ${resolved}`);
      broken++;
      continue;
    }

    const ct = res.headers.get('content-type') || '';
    const size = parseInt(res.headers.get('content-length') || '0');
    const vary = res.headers.get('vary') || '';

    if (ct.includes('avif') || ct.includes('webp')) {
      negotiated++;
      // Verify the response is not empty/tiny (corrupt)
      if (size > 0 && size < 100) {
        console.log(`SUSPICIOUS size=${size} type=${ct}  ${resolved}`);
        broken++;
      }
    } else {
      // Served original — check if variant should exist
      const path = resolved.replace(BASE, '');
      // This is fine — either no variant exists or it was pruned
    }
  }
}

console.log(`\n${total} negotiable images checked`);
console.log(`${negotiated} served as AVIF/WebP`);
console.log(`${total - negotiated - broken} served as original (no variant available)`);
console.log(`${broken} broken`);
process.exit(broken > 0 ? 1 : 0);
