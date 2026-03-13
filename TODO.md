# TODO

## Nginx & URL handling

- [x] **No trailing slashes.** Strip trailing `/` from all URLs site-wide.
- [x] **Vanity URL /cyc.** Serve `essays/posts/cyc/index.html` at `/cyc` directly (200, no redirect).
- [x] **Redirect long paths.** `essays/posts/cyc/index.html` and `essays/posts/cyc/` 301 to `/cyc`.
- [x] **Fix relative image paths.** `sub_filter` rewrites `src="figure/..."` to `src="/cyc/figure/..."`.
- [x] **Preserve fragments.** `#eurisko` survives — no intermediate `/cyc/` redirect step.
- [x] **Fix query string stripping.** nginx `rewrite` preserves query strings by default.
- [ ] **Deploy more vanity URL aliases.**
- [x] **Adding `.md` should show `.qmd` source verbatim.** `/cyc.md` serves raw `.qmd` as `text/plain`.
- [x] **Fix 403 on code directories.** Returns 404 now (no index.html); individual files still served.
- [ ] **Remove `/posts/` from URLs.** Visitors don't need to see implementation details. Default: `/logs/2025-gwern-bair` not `/logs/posts/2025-gwern-bair`. `/essays/structure-interpretation-chinese-economy` not `/essays/posts/structure-interpretation-chinese-economy`. Pages with vanity slugs (like `/cyc`) keep their slug. Needs nginx rewrite rules for all `*/posts/*` paths + redirects from old URLs.
- [ ] **Modularize nginx config.** Re-adopt the abandoned `_unused/` modular structure (`conf.d/`, `maps.d/`, `servers.d/`, `snippets/`) now that we have a sane test harness. Split the monolithic `nginx.conf` into includes.

## Search

- [x] **Slow first search load.** Truncated search.json 3.7MB → 506KB (86% reduction). Added `<link rel="prefetch">` for search.json. Added Cache-Control for .json in nginx.

## Cosmetic / UX

- [x] **Auto-detect dark/light mode.** Added `prefers-color-scheme` detection via `include-in-header` script.
- [ ] **Fix anchor scroll offset.** Jumping to `#eurisko` lands with the heading hidden behind the navbar.
- [ ] **Fix uncopyable text.** See: <https://chatgpt.com/share/691bfbcd-4e60-8009-9487-f5a4bbc140db>
- [ ] **Search only finds h2 headers, not h3+.**

## Deployment

To deploy these changes:
1. Re-render Quarto: `cd source && quarto render`
2. Run truncation: `python3 scripts/truncate-search-index.py`
3. Copy `server_infra/nginx/nginx.conf` to `/etc/nginx/nginx.conf` on the server
4. Test with `nginx -t` then `systemctl reload nginx`
