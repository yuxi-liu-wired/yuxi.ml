#!/usr/bin/env node
/**
 * Check compiled Quarto HTML for MathJax rendering errors.
 * MathJax renders undefined commands as <mtext mathcolor="red">\cmd</mtext>.
 * This script opens each page in a headless browser, waits for MathJax, and checks.
 */

import { createRequire } from "module";
const require = createRequire(import.meta.url);
const { chromium } = require("playwright");
import { readdir, stat } from "fs/promises";
import { join, relative } from "path";

const COMPILED_DIR = new URL("../quarto_compiled", import.meta.url).pathname;

async function findHtmlFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...(await findHtmlFiles(full)));
    } else if (entry.name.endsWith(".html")) {
      files.push(full);
    }
  }
  return files;
}

async function main() {
  const files = await findHtmlFiles(COMPILED_DIR);
  console.log(`Scanning ${files.length} HTML files...\n`);

  const browser = await chromium.launch();
  const context = await browser.newContext();
  let totalErrors = 0;

  for (const file of files) {
    const rel = relative(COMPILED_DIR, file);
    const page = await context.newPage();

    try {
      await page.goto(`file://${file}`, { waitUntil: "load", timeout: 15000 });

      // Wait for MathJax to finish (it sets a typesetPromise or we can poll)
      await page.waitForFunction(() => {
        if (!window.MathJax) return true; // no MathJax on this page
        if (window.MathJax.startup?.promise) {
          return window.MathJax.startup.promise.then(() => true).catch(() => true);
        }
        return true;
      }, { timeout: 10000 }).catch(() => {});

      // Small extra wait for rendering to settle
      await page.waitForTimeout(500);

      // Find mathcolor="red" elements whose text starts with \ (undefined commands)
      const errors = await page.evaluate(() => {
        const els = document.querySelectorAll('[mathcolor="red"]');
        return Array.from(els)
          .map((el) => el.textContent.trim())
          .filter((t) => t.startsWith("\\"));
      });

      if (errors.length > 0) {
        const unique = [...new Set(errors)];
        console.log(`${rel}`);
        for (const cmd of unique) {
          console.log(`  ${cmd} (${errors.filter((e) => e === cmd).length}x)`);
        }
        console.log();
        totalErrors += errors.length;
      }
    } catch (err) {
      console.log(`${rel}: SKIPPED (${err.message})`);
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
