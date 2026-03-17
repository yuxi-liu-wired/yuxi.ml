#!/usr/bin/env node
// Unified performance test with throttling profiles.
//
// Usage:
//   node scripts/perf-test.mjs                     # full local, mobile-4g throttle
//   node scripts/perf-test.mjs --live               # full live
//   node scripts/perf-test.mjs --quick              # scores only, no details
//   node scripts/perf-test.mjs --throttle broadband # desktop broadband simulation
//   node scripts/perf-test.mjs --throttle 3g        # slow 3G
//   node scripts/perf-test.mjs --throttle none      # raw, no throttling
//   node scripts/perf-test.mjs --threshold 60       # custom min score
//   node scripts/perf-test.mjs --desktop            # desktop viewport + broadband
//   node scripts/perf-test.mjs --page /cyc          # test a single page

import { readdirSync } from 'fs';
import { join } from 'path';
import lighthouse, { desktopConfig } from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';

// ── Chromium auto-detection ──
const PW_DIR = join(process.env.HOME, '.cache', 'ms-playwright');
const chromium = readdirSync(PW_DIR).filter(d => d.startsWith('chromium-')).sort().pop();
if (!chromium) { console.error('No Chromium found in ' + PW_DIR); process.exit(1); }
const CHROME_PATH = join(PW_DIR, chromium, 'chrome-linux64', 'chrome');

// ── Throttling profiles ──
const THROTTLE_PROFILES = {
  '4g': {
    name: 'Mobile Slow 4G (default)',
    throttling: {
      rttMs: 150, throughputKbps: 1638.4,
      requestLatencyMs: 562.5, downloadThroughputKbps: 1474.56,
      uploadThroughputKbps: 675, cpuSlowdownMultiplier: 4,
    },
  },
  '3g': {
    name: 'Mobile Regular 3G',
    throttling: {
      rttMs: 300, throughputKbps: 700,
      requestLatencyMs: 1125, downloadThroughputKbps: 630,
      uploadThroughputKbps: 630, cpuSlowdownMultiplier: 4,
    },
  },
  'broadband': {
    name: 'Desktop Broadband',
    throttling: {
      rttMs: 40, throughputKbps: 10240,
      requestLatencyMs: 0, downloadThroughputKbps: 0,
      uploadThroughputKbps: 0, cpuSlowdownMultiplier: 1,
    },
  },
  'none': {
    name: 'No Throttling',
    throttlingMethod: 'provided',
    throttling: {
      rttMs: 0, throughputKbps: 0,
      requestLatencyMs: 0, downloadThroughputKbps: 0,
      uploadThroughputKbps: 0, cpuSlowdownMultiplier: 1,
    },
  },
};

// ── CLI args ──
const args = process.argv.slice(2);
const hasFlag = (f) => args.includes(f);
const flagVal = (f) => { const i = args.indexOf(f); return i !== -1 ? args[i + 1] : null; };

const live = hasFlag('--live');
const quick = hasFlag('--quick');
const desktop = hasFlag('--desktop');
const THRESHOLD = parseInt(flagVal('--threshold') || '40', 10);
const throttleKey = flagVal('--throttle') || (desktop ? 'broadband' : '4g');
const singlePage = flagVal('--page');

if (hasFlag('--help') || hasFlag('-h')) {
  console.log(`Usage: node scripts/perf-test.mjs [options]

Options:
  --live              Test against https://yuxi.ml (default: localhost:8080)
  --quick             Scores only, skip detailed output
  --desktop           Desktop viewport + broadband throttle
  --throttle PROFILE  Network profile: 4g (default), 3g, broadband, none
  --threshold N       Minimum score per category (default: 40)
  --page PATH         Test a single page (e.g. /cyc)
  --help              Show this help`);
  process.exit(0);
}

const profile = THROTTLE_PROFILES[throttleKey];
if (!profile) {
  console.error(`Unknown throttle profile: ${throttleKey}`);
  console.error(`Available: ${Object.keys(THROTTLE_PROFILES).join(', ')}`);
  process.exit(1);
}

const BASE = live ? 'https://yuxi.ml' : 'http://localhost:8080';
const ALL_PAGES = [
  { name: 'Home', path: '/' },
  { name: '/cyc', path: '/cyc' },
  { name: '/essays', path: '/essays' },
];
const PAGES = singlePage
  ? [{ name: singlePage, path: singlePage }]
  : ALL_PAGES;
const CATEGORIES = ['performance', 'accessibility', 'best-practices', 'seo'];

// ── Lighthouse config ──
function buildConfig() {
  if (desktop) {
    // Start from Lighthouse's desktop preset, override throttling
    return {
      ...desktopConfig,
      settings: {
        ...desktopConfig.settings,
        ...(profile.throttlingMethod ? { throttlingMethod: profile.throttlingMethod } : {}),
        throttling: profile.throttling,
      },
    };
  }
  // Mobile config with custom throttling
  return {
    extends: 'lighthouse:default',
    settings: {
      ...(profile.throttlingMethod ? { throttlingMethod: profile.throttlingMethod } : {}),
      throttling: profile.throttling,
    },
  };
}

// ── Run ──
const mode = quick ? 'quick' : 'full';
const target = live ? 'live' : 'local';
console.log(`${mode} ${target} | ${profile.name} | threshold=${THRESHOLD} | ${chromium}\n`);

const failures = [];
const results = [];

for (const page of PAGES) {
  const url = BASE + page.path;
  const chrome = await chromeLauncher.launch({
    chromePath: CHROME_PATH,
    chromeFlags: ['--headless=new', '--no-sandbox', '--disable-gpu', '--disable-dev-shm-usage'],
  });

  try {
    console.log(`━━━ ${page.name} (${url}) ━━━`);
    const result = await lighthouse(url, {
      port: chrome.port,
      output: 'json',
      onlyCategories: CATEGORIES,
    }, buildConfig());

    const { categories, audits } = result.lhr;
    const scores = {};

    // Scores
    for (const [key, cat] of Object.entries(categories)) {
      const score = Math.round(cat.score * 100);
      scores[key] = score;
      const bar = score >= 90 ? '🟢' : score >= 50 ? '🟠' : '🔴';
      console.log(`  ${bar} ${cat.title}: ${score}`);
      if (score < THRESHOLD) {
        failures.push(`${page.name} ${cat.title}: ${score} < ${THRESHOLD}`);
      }
    }

    if (!quick) {
      // Core Web Vitals
      const cwv = ['first-contentful-paint', 'largest-contentful-paint', 'total-blocking-time',
                   'cumulative-layout-shift', 'speed-index'];
      const cwvLine = cwv
        .map(id => audits[id])
        .filter(Boolean)
        .map(a => `${a.acronym || a.id}: ${a.displayValue || a.numericValue}`)
        .join('  |  ');
      if (cwvLine) console.log(`  CWV: ${cwvLine}`);

      // Failed audits by weight
      const failed = [];
      for (const [, cat] of Object.entries(categories)) {
        for (const ref of cat.auditRefs) {
          const audit = audits[ref.id];
          if (audit && audit.score !== null && audit.score < 1 && ref.weight > 0) {
            failed.push({
              category: cat.title,
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
        console.log(`\n  Top issues (by weight):`);
        for (const f of failed.slice(0, 10)) {
          const s = Math.round(f.score * 100);
          console.log(`    [${f.category}] w=${f.weight} ${f.title} (${s}) ${f.displayValue}`);
        }
        if (failed.length > 10) console.log(`    ... and ${failed.length - 10} more`);
      }

      // Largest resources
      const payloads = audits['total-byte-weight'];
      if (payloads?.details?.items?.length) {
        console.log(`\n  Largest resources:`);
        for (const item of payloads.details.items.slice(0, 5)) {
          console.log(`    ${Math.round(item.totalBytes / 1024)}KB  ${item.url}`);
        }
      }
    }

    results.push({ page: page.name, scores });
    console.log('');
  } finally {
    await chrome.kill();
  }
}

// ── Summary ──
if (results.length > 1) {
  console.log('━━━ SUMMARY ━━━');
  const header = ['Page', ...CATEGORIES.map(c => c.slice(0, 4).toUpperCase())];
  console.log(`  ${header.map(h => h.padEnd(14)).join('')}`);
  for (const r of results) {
    const row = [r.page, ...CATEGORIES.map(c => String(r.scores[c]))];
    console.log(`  ${row.map(h => h.padEnd(14)).join('')}`);
  }
  console.log('');
}

if (failures.length > 0) {
  console.log(`FAIL: ${failures.length} score(s) below threshold ${THRESHOLD}:`);
  for (const f of failures) console.log(`  ✗ ${f}`);
  process.exit(1);
} else {
  console.log(`PASS: All scores ≥ ${THRESHOLD}`);
}
