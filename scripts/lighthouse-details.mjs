#!/usr/bin/env node
// Get detailed Lighthouse diagnostics for the home page.
import { readdirSync } from 'fs';
import { join } from 'path';
import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';

const PW_DIR = join(process.env.HOME, '.cache', 'ms-playwright');
const chromium = readdirSync(PW_DIR).filter(d => d.startsWith('chromium-')).sort().pop();
if (!chromium) throw new Error('No Chromium found in ' + PW_DIR);
const CHROME_PATH = join(PW_DIR, chromium, 'chrome-linux64', 'chrome');

async function run() {
  const chrome = await chromeLauncher.launch({
    chromePath: CHROME_PATH,
    chromeFlags: ['--headless=new', '--no-sandbox', '--disable-gpu', '--disable-dev-shm-usage'],
  });

  try {
    const result = await lighthouse('http://localhost:8080/', {
      port: chrome.port,
      output: 'json',
      onlyCategories: ['performance', 'accessibility', 'seo'],
    });

    const { audits } = result.lhr;

    const diagKeys = [
      'render-blocking-resources',
      'unminified-css',
      'unminified-javascript',
      'unused-css-rules',
      'unused-javascript',
      'modern-image-formats',
      'uses-optimized-images',
      'uses-responsive-images',
      'efficient-animated-content',
      'total-byte-weight',
      'dom-size',
      'largest-contentful-paint-element',
      'lcp-lazy-loaded',
      'layout-shifts',
      'long-tasks',
      'font-display',
    ];

    console.log('━━━ PERFORMANCE DIAGNOSTICS (Home) ━━━\n');
    for (const k of diagKeys) {
      const a = audits[k];
      if (!a) continue;
      const flag = a.score === null ? '⚪' : a.score < 1 ? '⚠️' : '✅';
      console.log(`${flag} ${a.title}`);
      if (a.displayValue) console.log(`   ${a.displayValue}`);
      if (a.details?.items?.length) {
        for (const item of a.details.items.slice(0, 5)) {
          const url = item.url || item.node?.snippet || item.source?.url || JSON.stringify(item).slice(0, 150);
          const size = item.totalBytes ? ` (${Math.round(item.totalBytes / 1024)}KB)` : '';
          const waste = item.wastedBytes ? ` waste=${Math.round(item.wastedBytes / 1024)}KB` : '';
          console.log(`   → ${url}${size}${waste}`);
        }
        if (a.details.items.length > 5)
          console.log(`   ... and ${a.details.items.length - 5} more`);
      }
      console.log('');
    }

    console.log('━━━ ACCESSIBILITY ISSUES (Home) ━━━\n');
    const a11yKeys = ['image-alt', 'color-contrast', 'link-name', 'heading-order', 'aria-allowed-attr'];
    for (const k of a11yKeys) {
      const a = audits[k];
      if (!a || a.score === 1) continue;
      console.log(`⚠️ ${a.title}`);
      if (a.details?.items?.length) {
        for (const item of a.details.items.slice(0, 5)) {
          console.log(`   → ${item.node?.snippet || item.node?.selector || JSON.stringify(item).slice(0, 150)}`);
        }
        if (a.details.items.length > 5)
          console.log(`   ... and ${a.details.items.length - 5} more`);
      }
      console.log('');
    }

    console.log('━━━ SEO ISSUES (Home) ━━━\n');
    const seoKeys = ['meta-description', 'image-alt', 'document-title'];
    for (const k of seoKeys) {
      const a = audits[k];
      if (!a || a.score === 1) continue;
      console.log(`⚠️ ${a.title}: ${a.displayValue || ''}`);
      console.log('');
    }
  } finally {
    await chrome.kill();
  }
}

run().catch(e => { console.error(e); process.exit(1); });
