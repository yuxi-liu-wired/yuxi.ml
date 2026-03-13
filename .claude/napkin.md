# Napkin — yuxi.ml

## Verification protocol

1. Tool/test says X is broken → `curl` the live URL and check the actual HTTP response
2. If the tool is wrong → fix the tool/config
3. If the tool is right → fix the issue immediately, don't list it as a recommendation
4. Every layer can lie: Quarto source, compiled HTML, nginx config, caching, CDN, the test tool itself
5. The only truth is what `curl https://yuxi.ml/...` returns

## Build pipeline

1. `cd source && quarto render`
2. `python3 scripts/truncate-search-index.py`
3. `node scripts/generate-image-variants.mjs`
4. `npx html-validate "quarto_compiled/**/*.html"` — must pass with 0 errors
5. Commit source first, compiled output separately
6. `bash deploy.sh`

## Current test harnesses

- **nginx tests**: `bash server_infra/nginx/test-nginx.sh` — 30 tests, runs in pre-commit hook
- **html-validate**: `npx html-validate "quarto_compiled/**/*.html"` — runs in pre-commit hook, 0 errors / ~518 warnings
- **Lighthouse**: `node scripts/lighthouse-audit.mjs` (local) / `node scripts/lighthouse-live.mjs` (production) — manual

## Known content issues (not our problem)

- `<font>` tags in docs/posts (embedded legacy HTML)
- World Bank iframe deprecated attrs
- ~518 missing alt attributes across posts (tracked as warnings)
- Draft stubs emit empty HTML (Quarto behavior)
