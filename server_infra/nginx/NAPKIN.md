# Nginx Napkin — WTFs and Learnings

## 2026-03-13: The Great Trailing Slash Fix

### WTF #1: `try_files $uri $uri/ =404` adds trailing slashes
When `$uri/` matches a directory, nginx does an internal redirect to `$uri/` which
triggers an external 301 redirect to add a trailing slash. Example: `/about` → 301 to `/about/`.
**Fix:** Use `try_files $uri $uri/index.html =404` to serve the index file directly.

### WTF #2: `alias` + `try_files` is buggy
With `alias /path/to/dir/;` and `try_files $uri $uri/ =404`, the `$uri` in `try_files`
uses the original URI, not the aliased path. This causes files to not be found.
**Fix:** Use `rewrite ... last` instead of `alias` to remap paths, then let the default
location handle serving.

### WTF #3: Relative paths break without trailing slash
When serving `/cyc` (no trailing slash), browser resolves `figure/foo.png` as
`/figure/foo.png` instead of `/cyc/figure/foo.png`. With trailing slash `/cyc/`,
the base is `/cyc/` and relative paths work. This affects ALL pages, not just vanity URLs.
Listing pages like `/essays` have `src="posts/foo/figure/bar.png"` which resolves
against `/` when served at `/essays` (no slash) → `/posts/foo/figure/bar.png` → 404.
**Fix:** Build-time `absolutify-figure-paths.py` rewrites ALL relative `src`/`href` to
absolute paths using `posixpath.normpath`. Must catch every pattern (not just `figure/`
and `code/`). Use muffet as ground truth test — if muffet finds 404s, the script missed
something. Re-render Quarto, re-run absolutify, re-test with muffet.

### WTF #4: `pipefail` + `grep -q` on large pipes
`curl | grep -qF` fails with `pipefail` because `grep -q` closes stdin early after
finding a match, causing `curl` to get SIGPIPE (exit 141). Pipeline returns 141.
**Fix:** Write curl output to a temp file first, then grep the file.

### WTF #5: HSTS header drops in location blocks with `add_header`
`add_header` is NOT inherited from server level if ANY `add_header` exists in the
location block. The static-asset location with `add_header Cache-Control` silently
drops the HSTS header from server level.
**Fix:** Repeat HSTS in every location that has its own `add_header`.

### Hard blocker: gixy
gixy (nginx security linter) can't be installed in the Claudebox — no pip, not in pixi.
Run it manually on another machine: `pip install gixy && gixy nginx.conf`

### WTF #6: muffet exclude regex was excluding everything
`muffet -e 'https?://'` excludes ALL URLs matching that regex — including
`http://localhost:8080/...`. muffet silently checked nothing and reported 0 errors.
**Fix:** Use `muffet -e 'https?://[^/]*\.[a-z]'` — matches hostnames with dots
(all external domains) but not `localhost` (no dot in hostname).

### WTF #7: Listing thumbnails — Quarto `image:` field
Posts without an active `image:` frontmatter field generate bare `posts/...` thumbnail
paths on listing pages. Posts WITH `image:` get correct `../section/posts/...` paths.
**Fix:** Either add `image:` to all posts, or catch `posts/` in absolutify script.

### WTF #8: Regex location `[^/]+` matches file extensions
When stripping `/posts/` from URLs, the post page location `^/(section)/([^/]+)$`
also matched `.md` URLs like `/essays/slug.md`, stealing them from the `.md` handler.
Regex locations match in order of appearance — first match wins.
**Fix:** Use `[^/.]+` to exclude dots from slug matching. Post slugs never contain dots.
Same issue in server-level rewrite: `[^/.]+` prevents matching `slug.md` as a redirect.

### Architecture
```
server-level rewrites:
  1. vanity redirect: /essays/posts/cyc → /cyc
  2. strip /posts/: /section/posts/slug → /section/slug (301)
  3. trailing slash strip
  4. index.html strip
    ↓ (if no redirect)
location = /cyc              → try_files (exact vanity page)
location ^~ /cyc/            → rewrite ... last (vanity sub-resources)
location ~ /section/slug$    → try_files /section/posts/slug/index.html (short post URLs)
location ~ /section/slug/..  → rewrite ... last (short post sub-resources → re-match)
location ~ /code             → autoindex
location ~ \.md$             → rewrite to index.md, try_files
location ~* \.(png|jpg|gif)$ → AVIF/WebP negotiation + cache headers
location ~* \.(css|js|...)$  → cache headers
location /                   → try_files $uri $uri/index.html =404 (default)
```
