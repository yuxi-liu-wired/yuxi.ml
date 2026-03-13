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
the base is `/cyc/` and relative paths work.
**Fix:** Use `sub_filter` to rewrite `src="figure/"` to `src="/cyc/figure/"` in the HTML
response. This is cleaner than `<base href>` which breaks in-page anchor links.

### WTF #4: `pipefail` + `grep -q` on large pipes
`curl | grep -qF` fails with `pipefail` because `grep -q` closes stdin early after
finding a match, causing `curl` to get SIGPIPE (exit 141). Pipeline returns 141.
**Fix:** Write curl output to a temp file first, then grep the file.

### WTF #5: HSTS header drops in location blocks with `add_header`
`add_header` is NOT inherited from server level if ANY `add_header` exists in the
location block. The static-asset location with `add_header Cache-Control` silently
drops the HSTS header from server level.
**Fix:** Repeat HSTS in every location that has its own `add_header`.

### Architecture
```
server-level rewrites (vanity redirect, trailing slash strip, index.html strip)
    ↓ (if no redirect)
location = /cyc          → sub_filter + try_files (exact page)
location ^~ /cyc/        → rewrite ... last (sub-resources → real path → re-match)
location ~* \.(ext)$     → cache headers + try_files (static assets, incl. rewritten /cyc/* paths)
location /               → try_files $uri $uri/index.html =404 (default)
```
