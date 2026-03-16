# Napkin — yuxi.ml

## Verification protocol

1. Tool/test says X is broken → `curl` the live URL and check the actual HTTP response
2. If the tool is wrong → fix the tool/config
3. If the tool is right → fix the issue immediately, don't list it as a recommendation
4. Every layer can lie: Quarto source, compiled HTML, nginx config, caching, CDN, the test tool itself
5. The only truth is what `curl https://yuxi.ml/...` returns
6. For images: use Playwright (`check-browser-images.cjs`) — curl can't catch relative-path resolution bugs

## Build pipeline

1. `cd source && quarto render`
2. `python3 scripts/truncate-search-index.py`
3. `node scripts/generate-image-variants.mjs`
4. `pixi run python scripts/subset-bootstrap-icons.py`
5. `npx html-validate "quarto_compiled/**/*.html"` — must pass with 0 errors
6. Commit source first, compiled output separately
7. `bash remote-deploy.sh`

## Current test harnesses (fast → slow)

1. **nginx tests**: `bash server_infra/nginx/test-nginx.sh` — 31 tests incl muffet crawl, runs in pre-commit hook (~15s)
2. **html-validate**: `npx html-validate "quarto_compiled/**/*.html"` — runs in pre-commit hook, 0 errors / ~518 warnings (~20s)
3. **Browser image check**: `node scripts/check-browser-images.cjs` — Playwright checks every img on every page (~60s)
4. **Lighthouse**: `node scripts/lighthouse-audit.mjs` (local) / `node scripts/lighthouse-live.mjs` (production) — manual (~90s)

## Key nginx mechanisms

- **`<base href>` injection**: `sub_filter` injects `<base href="$request_uri/">` into HTML responses so Quarto's relative paths resolve correctly even without trailing slashes. Controlled by `map $request_uri $base_tag`.
- **Image content negotiation**: `map $http_accept $img_suffix` + `try_files $uri$img_suffix` serves AVIF/WebP transparently.
- **Trailing slash strip**: `rewrite ^(.+(?<!/code))/$ $1 permanent` — exempts `/code/` for autoindex.

## Known content issues (not our problem)

- Missing `banner.png` for philosophical-sketches (1 broken image site-wide)
- `<font>` tags in docs/posts (embedded legacy HTML)
- World Bank iframe deprecated attrs
- ~518 missing alt attributes across posts (tracked as warnings)
- Draft stubs emit empty HTML (Quarto behavior)
