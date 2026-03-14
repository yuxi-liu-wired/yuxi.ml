# CLAUDE.md — yuxi.ml

## What this is

Personal website of Yuxi Liu, built with Quarto and served by nginx on a VPS.

## Project structure

```
source/           — Quarto source files (.qmd)
source/_quarto.yml — Quarto config
quarto_compiled/  — Quarto output (HTML, assets) — this is what gets deployed
server_infra/nginx/ — nginx configs (production + local test)
scripts/          — utility scripts
remote-deploy.sh  — tags, pushes, SSHs to server to deploy
```

## Build & deploy

- **Quarto render**: `cd source && quarto render` → outputs to `quarto_compiled/`
- **Image optimization**: `node scripts/generate-image-variants.mjs` → generates `.avif` and `.webp` siblings for every image in `quarto_compiled/`. Run after every `quarto render`.
- **Deploy**: `bash remote-deploy.sh` — tags `deploy-YYYY-MM-DD`, pushes to GitHub, SSHs to `yuxi-ml` and runs remote deploy. Multiple deploys per day get `.1`, `.2`, etc.
- **Local nginx test**: `bash server_infra/nginx/test-local.sh` (serves on localhost:8080)
- **Lighthouse audit**: `node scripts/lighthouse-audit.mjs` (local) or `node scripts/lighthouse-live.mjs` (production). Requires Chromium.

## Nginx conventions

- Production config: `server_infra/nginx/nginx.conf`
- Local test config: `server_infra/nginx/test-local.conf`
- Test suite: `server_infra/nginx/test-nginx.sh`
- **Always test locally before deploying.** nginx behavior is surprising; do not reason from first principles.
- The production server has `--with-http_sub_module` (nginx 1.28 mainline).
- The local container has nginx 1.22.1 with `--with-http_sub_module`.
- Web root on production: `/var/www/yuxi.ml` (mirrors `quarto_compiled/`)
- Ports 8080–8099 are forwarded from this container to the host.

## Image optimization

nginx serves optimized image formats automatically via content negotiation:

- **Build step**: `node scripts/generate-image-variants.mjs` generates `.avif` (q50) and `.webp` (q75) files alongside every `.png`/`.jpg`/`.jpeg` in `quarto_compiled/`. Derivatives larger than the original are pruned. Requires `sharp` (npm).
- **nginx**: A `map $http_accept $img_suffix` block in the `http` context picks `.avif` or `.webp` based on the browser's `Accept` header. The image `location` block does `try_files $uri$img_suffix $uri =404` with `Vary: Accept`.
- **Result**: Browsers get AVIF (~89% smaller) or WebP (~83% smaller) transparently. No HTML changes needed — `<img src="photo.png">` still works.
- **File naming**: `photo.png.avif` and `photo.png.webp` (suffix appended, not replaced).

## Vanity URLs

Short vanity paths map to long Quarto output paths:
- `/cyc` → `essays/posts/cyc/index.html`
- More may be added later.

When adding vanity URLs, you must handle:
1. Serving the page at the short path (no trailing slash)
2. Redirecting the long path to the short path
3. Serving sub-resources (figures, code) at the vanity prefix

## Testing philosophy

- **Verify end-to-end, never trust a single layer.** When a tool (Lighthouse, linter, test suite) reports an issue, verify it against what the server actually delivers: `curl` the live URL. Any layer can lie — Quarto might emit it but nginx might strip it, caching might be stale, the tool might be wrong. The only truth is the HTTP response the browser receives.
- **Test actual behavior, not inferred intent.** Don't check whether HTML contains "absolute paths" — check whether the browser would get a 404. The test should fetch every page, extract every `src`/`href`, resolve it the way a browser would, and verify the asset actually serves 200.
- **Do NOT "fix" Quarto output with post-processing scripts.** Quarto generates relative paths for a reason. If they break, the problem is in nginx (how URLs are served), not in the HTML. Fix the serving layer.
- **nginx is the source of truth.** The test suite hits the actual running nginx. If the test says it's broken, it's broken. If the test says it's fine but the browser disagrees, the test is wrong.
- **Content bugs are Yuxi's responsibility.** Missing source files (e.g. `banner.png`), broken cross-references to directories, and issues inside embedded third-party HTML (World Bank iframes) are content-level problems that require Quarto source edits. These are tracked in TODO.md under "Content fixes (Yuxi's responsibility)". The test suite excludes these known issues from muffet so the nginx tests stay green.

## Style & URL policy

- **No trailing slashes.** `/cyc` not `/cyc/`. `/essays` not `/essays/`.
- **Canonical short URLs.** `/cyc` not `/essays/posts/cyc/index.html`.
- **Fragments preserved.** `/cyc#eurisko` must work, never `/cyc/#eurisko`.

## Content authorship

- **Never write user-facing plaintext content.** Descriptions, bios, page copy, and anything that represents Yuxi's voice must be written by Yuxi.
- **Use obvious placeholders** like `"TODO(yuxi): describe this page"` and add the item to TODO.md under "Content fixes (Yuxi's responsibility)".
- **Mechanical/factual text is fine**: alt text like `"Yuxi Liu"` for a profile photo, config values, code comments.

## Git conventions

- **Make small, focused commits.** One logical change per commit (e.g., "fix nginx vanity URL", "add dark mode detection", "truncate search index"). Never bundle unrelated changes into a giant blob.
- **Commit messages** should say *what* and *why*, not *how*. Keep them concise.
- **Don't commit `quarto_compiled/`** changes alongside source changes — they're deployment artifacts. Commit source changes first, then separately commit compiled output after `quarto render`.

## Quarto notes

- Themes: flatly (light) + darkly (dark) with custom SCSS overrides
- Search: uses Quarto's built-in fuse.js search with a JSON index (`search.json`). Run `python3 scripts/truncate-search-index.py` after `quarto render` to trim it (~3.7MB → ~500KB).
- Site URL: `https://yuxi.ml/`
- Output dir: `../quarto_compiled` (relative to `source/`)
