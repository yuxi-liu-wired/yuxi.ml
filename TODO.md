# TODO

## Nginx & URL handling

- [x] **No trailing slashes.** Strip trailing `/` from all URLs site-wide.
- [x] **Vanity URL /cyc.** Serve `essays/posts/cyc/index.html` at `/cyc` directly (200, no redirect).
- [x] **Redirect long paths.** `essays/posts/cyc/index.html` and `essays/posts/cyc/` 301 to `/cyc`.
- [x] **Fix relative image paths.** Build-time `absolutify-figure-paths.py` rewrites relative `figure/` and `code/` paths to absolute.
- [x] **Preserve fragments.** `#eurisko` survives — no intermediate `/cyc/` redirect step.
- [x] **Fix query string stripping.** nginx `rewrite` preserves query strings by default.
- [ ] **Deploy more vanity URL aliases.**
- [x] **Adding `.md` should show `.qmd` source verbatim.** `/cyc.md` serves raw `.qmd` as `text/plain`.
- [x] **Fix 403 on code directories.** Individual files still served.
- [x] **Fix listing page thumbnails.** Fixed by `absolutify-figure-paths.py`. Root cause: posts without explicit `image:` frontmatter get bare relative paths from Quarto's auto-discovery. The absolutify script catches these. For a cleaner fix, add `image:` to each post (see "Content fixes" section below).
- [x] **Remove `/posts/` from URLs.** Visitors don't need to see implementation details. Default: `/logs/2025-gwern-bair` not `/logs/posts/2025-gwern-bair`. `/essays/structure-interpretation-chinese-economy` not `/essays/posts/structure-interpretation-chinese-economy`. Pages with vanity slugs (like `/cyc`) keep their slug. See `server_infra/nginx/FEATURES.md` (2026-03-14).
- [ ] **Modularize nginx config.** Re-adopt the abandoned `_unused/` modular structure (`conf.d/`, `maps.d/`, `servers.d/`, `snippets/`) now that we have a sane test harness. Split the monolithic `nginx.conf` into includes.

## Search

- [x] **Slow first search load.** Truncated search.json 3.7MB → 506KB (86% reduction). Added `<link rel="prefetch">` for search.json. Added Cache-Control for .json in nginx.

## Cosmetic / UX

- [x] **Auto-detect dark/light mode.** Added `prefers-color-scheme` detection via `include-in-header` script.
- [ ] **Fix anchor scroll offset.** Jumping to `#eurisko` lands with the heading hidden behind the navbar.
- [ ] **Fix uncopyable text.** See: <https://chatgpt.com/share/691bfbcd-4e60-8009-9487-f5a4bbc140db>
- [ ] **Search only finds h2 headers, not h3+.**

## Content fixes (Yuxi's responsibility)

These are content/source issues that Claude can't fix — they need manual Quarto source edits:

- [ ] **Missing banner.png for philosophical-sketches.** `image: "figure/banner.png"` in frontmatter but `sketches/posts/philosophical-sketches/figure/banner.png` doesn't exist. Either create the image or remove the `image:` field.
- [x] **Broken cross-ref to nick-land code directory.** Fixed with `autoindex on` for `/code/` paths in nginx. `/code` → `/code/` → directory listing.
- [ ] **World Bank iframe refs.** Embedded World Bank HTML files reference `/favicon.ico` and `/indicator/...` which 404 on our domain. Either host the iframes locally with fixed paths, or accept the 404s (currently excluded from muffet tests).
- [ ] **Add `image:` frontmatter to posts missing it.** Posts without explicit `image:` get auto-discovered thumbnails with bare relative paths (fixed at build-time by absolutify, but adding `image:` is cleaner). Affected posts:
  - `essays/posts/scaling-law-by-data-manifold/` — uncomment `# image: "figure/banner.png"`
  - `essays/posts/grokking-modular-arithmetics/` — uncomment `# image: "figure/banner.png"`
  - `sketches/posts/neural-network-scrapbook/` — uncomment `# image: "figure/banner.png"`
  - `sketches/posts/fictional-ideas/` — uncomment `# image: "figure/banner.png"`
  - `sketches/posts/field-theory-how-to/` — uncomment `# image: "figure/banner.png"`
  - `sketches/posts/linux-notes/` — uncomment `# image: "figure/banner_1.png"`
  - `sketches/posts/research-ideas/` — uncomment `# image: "figure/banner.png"`
  - `sketches/posts/web-design-notes/` — uncomment `# image: "figure/banner_1.png"`
  - `logs/posts/2025-patel-dinner/` — add `image:` field
  - `logs/posts/2025-reprofro-party/` — add `image:` field
  - `logs/posts/2025-whalefall/` — add `image:` field
  - `logs/posts/2026-akses-ditolak/` — add `image:` field

## Deployment

To deploy these changes:
1. Re-render Quarto: `cd source && quarto render`
2. Run truncation: `python3 scripts/truncate-search-index.py`
3. Generate image variants: `node scripts/generate-image-variants.mjs`
4. Copy `server_infra/nginx/nginx.conf` to `/etc/nginx/nginx.conf` on the server
5. Test with `nginx -t` then `systemctl reload nginx`
