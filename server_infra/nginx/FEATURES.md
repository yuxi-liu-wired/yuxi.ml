# Nginx Features — yuxi.ml

Dated log of nginx URL features. Each entry documents what the feature does,
how it works, and what to watch out for.

---

## 2026-03-14: Strip `/posts/` from section URLs

**What:** Post URLs no longer include `/posts/`. Old URLs 301-redirect to new ones.

| Before | After |
|--------|-------|
| `/essays/posts/scaling-law-by-data-manifold` | `/essays/scaling-law-by-data-manifold` |
| `/logs/posts/2025-gwern-bair` | `/logs/2025-gwern-bair` |
| `/docs/posts/1987-09-nick-land` | `/docs/1987-09-nick-land` |
| `/sketches/posts/neural-network-scrapbook` | `/sketches/neural-network-scrapbook` |

Posts with vanity slugs (e.g. `/cyc`) keep their slug — the vanity rewrites fire first.

**How it works:**

1. **Server-level rewrites** (processed first, before location blocks):
   - `^/(essays|logs|docs|sketches)/posts/([^/.]+)/index\.html$` → `/$1/$2` (301)
   - `^/(essays|logs|docs|sketches)/posts/([^/.]+)/?$` → `/$1/$2` (301)
   - Uses `[^/.]+` (not `[^/]+`) to avoid matching file extensions like `.md`

2. **Post page location** `~ ^/(section)/(?!posts(?:/|$))([^/.]+)$`:
   - Serves `/section/slug` from `/section/posts/slug/index.html` via `try_files`
   - Negative lookahead `(?!posts)` prevents matching the literal word "posts" as a slug
   - `[^/.]+` prevents matching `.md` files (which have their own handler)
   - Injects `<base href>` via `sub_filter` for relative path resolution

3. **Sub-resource location** `~ ^/(section)/(?!posts(?:/|$))([^/]+)/(.+)$`:
   - Rewrites `/section/slug/figure/foo.png` → `/section/posts/slug/figure/foo.png`
   - Uses `rewrite ... last` so the rewritten URL re-matches other locations
   - This means image negotiation (AVIF/WebP), code autoindex, etc. still apply

4. **`.md` handler** updated with a new first rule:
   - `/section/slug.md` → `/section/posts/slug/index.md` (short post URL)
   - Falls through to existing `/foo.md` → `/foo/index.md` for non-post pages

**What still works at old paths:**
- Sub-resources like `/essays/posts/slug/figure/foo.png` still serve directly (no redirect)
- The absolutified HTML references these old paths, so no content changes needed
- Old page URLs (`/essays/posts/slug`) 301-redirect to new short URLs

**Gotchas:**
- Post slugs must not contain dots (all current slugs use only `[a-z0-9-]`)
- The negative lookahead `(?!posts)` is essential — without it, the old-path sub-resources
  would match the short-URL location and double-nest `/posts/posts/...`
- Regex locations match in order of appearance (first wins); the post page location must
  appear before the `.md` location to avoid conflicts, but uses `[^/.]+` to let `.md` through

---

## 2026-03-13: Vanity URL `/cyc`

**What:** `/cyc` serves the essay at `/essays/posts/cyc/index.html` directly (200, no redirect).
Old paths (`/essays/posts/cyc`, `/essays/posts/cyc/index.html`) 301-redirect to `/cyc`.

**How it works:**
- `location = /cyc` — exact match, serves via `try_files`
- `location ^~ /cyc/` — prefix match, rewrites sub-resources to real path
- `location = /cyc.md` — serves raw `.qmd` source as `text/plain`
- Server-level rewrites catch old paths and 301 to `/cyc`

---

## 2026-03-13: Trailing slash and index.html stripping

**What:** URLs never have trailing slashes or `index.html`. `/about/` → `/about`, `/about/index.html` → `/about`.

**How it works:**
- `rewrite ^(.+(?<!/code))/$ $1 permanent` — strip trailing slash (exempt `/code/` for autoindex)
- `rewrite ^(/.+)/index\.html$ $1 permanent` — strip index.html
- Default location uses `try_files $uri $uri/index.html =404` to serve directories

---

## 2026-03-13: `.md` source file serving

**What:** Appending `.md` to any page URL serves the raw Quarto `.qmd` source as `text/plain`.

**How it works:**
- `location ~ \.md$` with `default_type text/plain`
- Rewrites `/foo.md` → `/foo/index.md` internally
- Vanity URLs handled by exact match (`location = /cyc.md`)

---

## 2026-03-13: Image format negotiation

**What:** Browsers automatically get AVIF or WebP versions of images based on `Accept` header.

**How it works:**
- Build step: `generate-image-variants.mjs` creates `.avif` and `.webp` alongside originals
- `map $http_accept $img_suffix` picks the best format
- Image location uses `try_files $uri$img_suffix $uri =404`
- `Vary: Accept` header for correct caching

---

## 2026-03-13: Base href injection

**What:** Pages served without trailing slashes get `<base href="/path/">` injected so relative URLs resolve correctly.

**How it works:**
- `map $request_uri $base_tag` generates the tag (empty for URLs ending in `/` or `.html`)
- `sub_filter '<head>' '<head>${base_tag}'` injects it into HTML responses
- Combined with `absolutify-figure-paths.py` which makes most paths absolute at build time
