#!/usr/bin/env node
// Generate .avif and .webp variants alongside every .png/.jpg/.jpeg in quarto_compiled/.
// Skips files that already have up-to-date variants.
// Usage: node scripts/generate-image-variants.mjs [--dry-run]

import sharp from 'sharp';
import { readdir, stat, unlink } from 'fs/promises';
import { join, extname } from 'path';

const ROOT = 'quarto_compiled';
const DRY_RUN = process.argv.includes('--dry-run');
const EXTS = new Set(['.png', '.jpg', '.jpeg']);

// Concurrency limit to avoid OOM on large images
const CONCURRENCY = 4;

async function* walkImages(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = join(dir, e.name);
    if (e.isDirectory()) yield* walkImages(full);
    else if (EXTS.has(extname(e.name).toLowerCase())) yield full;
  }
}

async function needsUpdate(src, dest) {
  try {
    const [srcStat, destStat] = await Promise.all([stat(src), stat(dest)]);
    return srcStat.mtimeMs > destStat.mtimeMs;
  } catch {
    return true; // dest doesn't exist
  }
}

let total = 0, converted = 0, skipped = 0, failed = 0, pruned = 0;

async function convert(src) {
  const variants = [
    { suffix: '.avif', fn: (s) => s.avif({ quality: 50, effort: 4 }) },
    { suffix: '.webp', fn: (s) => s.webp({ quality: 75, effort: 4 }) },
  ];

  for (const v of variants) {
    const dest = src + v.suffix;
    if (!(await needsUpdate(src, dest))) {
      skipped++;
      continue;
    }
    if (DRY_RUN) {
      console.log(`[dry-run] would create ${dest}`);
      converted++;
      continue;
    }
    try {
      await v.fn(sharp(src)).toFile(dest);
      // Delete derivative if it's larger than the original (not worth serving)
      const [srcSize, destSize] = await Promise.all([
        stat(src).then(s => s.size),
        stat(dest).then(s => s.size),
      ]);
      if (destSize >= srcSize) {
        await unlink(dest);
        pruned++;
        continue;
      }
      converted++;
    } catch (err) {
      console.error(`FAIL ${dest}: ${err.message}`);
      failed++;
    }
  }
}

// Process with bounded concurrency
const queue = [];
for await (const src of walkImages(ROOT)) {
  total++;
  queue.push(src);
}

console.log(`Found ${total} images in ${ROOT}`);
if (DRY_RUN) console.log('(dry run — no files will be written)\n');

// Process in batches
for (let i = 0; i < queue.length; i += CONCURRENCY) {
  const batch = queue.slice(i, i + CONCURRENCY);
  await Promise.all(batch.map(convert));
  if (!DRY_RUN && i % 40 === 0 && i > 0) {
    process.stdout.write(`  ${i}/${queue.length}...\n`);
  }
}

console.log(`\nDone: ${converted} created, ${skipped} up-to-date, ${pruned} pruned (larger than original), ${failed} failed`);
