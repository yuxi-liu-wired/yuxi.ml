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
**Wrong fix:** `sub_filter` or build-time scripts to rewrite HTML paths. These are
band-aids that infer intent instead of testing behavior — they'll always miss cases.
**Actual fix:** nginx must serve these URLs in a way that makes relative paths work.
Options: internal rewrite so the browser's base URL matches Quarto's expectations,
or use `<base href>` (but this breaks fragment links — test carefully).

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

### WTF #6: Don't test HTML content — test HTTP responses
`absolutify-figure-paths.py` rewrote `src="figure/"` to absolute paths in HTML, and
the test checked for the rewritten strings. But the script missed `src="posts/"` on
listing pages → 12 broken thumbnails that the test didn't catch.
**Lesson:** Never test "does the HTML look right." Test "does the asset URL return 200."
Crawl every page, extract every `src`/`href`, resolve it as a browser would, hit nginx.
That's the only test that catches what the user actually sees.

### Architecture
```
server-level rewrites (vanity redirect, trailing slash strip, index.html strip)
    ↓ (if no redirect)
location = /cyc          → try_files (exact page)
location ^~ /cyc/        → rewrite ... last (sub-resources → real path → re-match)
location ~* \.(ext)$     → cache headers + try_files (static assets, incl. rewritten /cyc/* paths)
location /               → try_files $uri $uri/index.html =404 (default)
```
