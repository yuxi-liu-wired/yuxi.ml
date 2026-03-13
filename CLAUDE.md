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
deploy.sh         — runs deploy on remote via ssh
```

## Build & deploy

- **Quarto render**: `cd source && quarto render` → outputs to `quarto_compiled/`
- **Deploy**: `bash deploy.sh` (requires SSH to `yuxi-ml` host)
- **Local nginx test**: `sudo bash server_infra/nginx/test-local.sh` (serves on localhost:8080)

## Nginx conventions

- Production config: `server_infra/nginx/nginx.conf`
- Local test config: `server_infra/nginx/test-local.conf`
- Test suite: `server_infra/nginx/test-nginx.sh`
- **Always test locally before deploying.** nginx behavior is surprising; do not reason from first principles.
- The production server has `--with-http_sub_module` (nginx 1.28 mainline).
- The local container has nginx 1.22.1 with `--with-http_sub_module`.
- Web root on production: `/var/www/yuxi.ml` (mirrors `quarto_compiled/`)
- Ports 8080–8099 are forwarded from this container to the host.

## Vanity URLs

Short vanity paths map to long Quarto output paths:
- `/cyc` → `essays/posts/cyc/index.html`
- More may be added later.

When adding vanity URLs, you must handle:
1. Serving the page at the short path (no trailing slash)
2. Redirecting the long path to the short path
3. Fixing relative asset paths (images, CSS, JS) via `sub_filter`
4. Serving sub-resources (figures, code) at the vanity prefix

## Style & URL policy

- **No trailing slashes.** `/cyc` not `/cyc/`. `/essays` not `/essays/`.
- **Canonical short URLs.** `/cyc` not `/essays/posts/cyc/index.html`.
- **Fragments preserved.** `/cyc#eurisko` must work, never `/cyc/#eurisko`.

## Git conventions

- **Make small, focused commits.** One logical change per commit (e.g., "fix nginx vanity URL", "add dark mode detection", "truncate search index"). Never bundle unrelated changes into a giant blob.
- **Commit messages** should say *what* and *why*, not *how*. Keep them concise.
- **Don't commit `quarto_compiled/`** changes alongside source changes — they're deployment artifacts. Commit source changes first, then separately commit compiled output after `quarto render`.

## Quarto notes

- Themes: flatly (light) + darkly (dark) with custom SCSS overrides
- Search: uses Quarto's built-in fuse.js search with a JSON index (`search.json`). Run `python3 scripts/truncate-search-index.py` after `quarto render` to trim it (~3.7MB → ~500KB).
- Site URL: `https://yuxi.ml/`
- Output dir: `../quarto_compiled` (relative to `source/`)
