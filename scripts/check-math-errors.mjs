#!/usr/bin/env node
/**
 * Check compiled Quarto HTML for KaTeX or MathJax rendering errors.
 *
 * KaTeX errors:  elements with class "katex-error"
 * MathJax errors: <mtext mathcolor="red">\cmd</mtext>
 *
 * Only checks index.html files (Quarto pages). Blocks external network
 * requests and uses domcontentloaded — checking DOM elements should be fast.
 */

import { createRequire } from "module";
const require = createRequire(import.meta.url);
let chromium;
try {
  ({ chromium } = require("playwright"));
} catch {
  ({ chromium } = require("/home/node/.bun/install/global/node_modules/playwright"));
}
import { readdir } from "fs/promises";
import { join, relative } from "path";

const COMPILED_DIR = new URL("../quarto_compiled", import.meta.url).pathname;

async function findPageFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...(await findPageFiles(full)));
    } else if (entry.name === "index.html" || (entry.name.endsWith(".html") && dir === COMPILED_DIR)) {
      // Only index.html (Quarto pages) + top-level HTML files (home, 404)
      files.push(full);
    }
  }
  return files;
}

async function main() {
  const files = await findPageFiles(COMPILED_DIR);
  console.log(`Scanning ${files.length} pages...\n`);

  const browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_PATH || undefined,
  });
  const context = await browser.newContext();

  // Block all external requests — we only need the local HTML DOM
  await context.route("**/*", (route) => {
    const url = route.request().url();
    if (url.startsWith("file://")) {
      route.continue();
    } else {
      route.abort();
    }
  });

  let totalErrors = 0;

  for (const file of files) {
    const rel = relative(COMPILED_DIR, file);
    const page = await context.newPage();

    try {
      await page.goto(`file://${file}`, { waitUntil: "domcontentloaded", timeout: 5000 });

      const errors = await page.evaluate(() => {
        const results = [];

        for (const el of document.querySelectorAll(".katex-error")) {
          const title = el.getAttribute("title") || "";
          const tex = el.textContent.trim();
          const match = title.match(/Undefined control sequence: (\\[a-zA-Z]+)/);
          const cmd = match ? match[1] : tex.slice(0, 40);
          results.push({ type: "katex", cmd, title: title.slice(0, 120) });
        }

        for (const el of document.querySelectorAll('[mathcolor="red"]')) {
          const t = el.textContent.trim();
          if (t.startsWith("\\")) {
            results.push({ type: "mathjax", cmd: t, title: "" });
          }
        }

        return results;
      });

      if (errors.length > 0) {
        const cmdCounts = {};
        for (const e of errors) {
          const key = e.cmd;
          if (!cmdCounts[key]) cmdCounts[key] = { count: 0, title: e.title };
          cmdCounts[key].count++;
        }
        console.log(`${rel}`);
        for (const [cmd, info] of Object.entries(cmdCounts)) {
          console.log(`  ${cmd} (${info.count}x)`);
        }
        console.log();
        totalErrors += errors.length;
      }
    } catch (err) {
      console.error(`ERROR: ${rel}: ${err.message}`);
      process.exitCode = 1;
    } finally {
      await page.close();
    }
  }

  await browser.close();

  if (totalErrors > 0) {
    console.log(`\n${totalErrors} math error(s) found.`);
    process.exit(1);
  } else {
    console.log("No math errors found.");
  }
}

main();
