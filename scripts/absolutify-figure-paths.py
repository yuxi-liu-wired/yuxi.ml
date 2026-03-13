#!/usr/bin/env python3
"""Convert relative src/href paths to absolute paths in HTML files.

Without trailing slashes, browsers resolve relative URLs against the parent
directory. This script rewrites all relative src="..." and href="..." to
absolute paths based on each file's location in quarto_compiled.

Skips: absolute paths (/...), URLs (http/https/data/javascript), fragments (#),
and mailto: links.

Usage: python3 scripts/absolutify-figure-paths.py
"""

import re
from pathlib import Path
from posixpath import normpath

ROOT = Path(__file__).resolve().parent.parent / "quarto_compiled"

# Match src="..." or href="..." where the value is a relative path.
# Negative lookahead skips absolute paths, URLs, fragments, mailto, data.
PATTERN = re.compile(
    r'((?:src|href)=")'        # group 1: attribute prefix
    r'(?!/)'                    # not absolute path
    r'(?!https?://)'           # not http(s) URL
    r'(?!data:)'               # not data URI
    r'(?!javascript:)'         # not javascript
    r'(?!mailto:)'             # not mailto
    r'(?!#)'                   # not fragment-only
    r'([^"]+)'                 # group 2: the relative path
)

count = 0
files_changed = 0

for html_file in ROOT.rglob("index.html"):
    text = html_file.read_text(encoding="utf-8")
    # Directory path relative to root, e.g. /essays/posts/cyc
    rel_dir = "/" + str(html_file.parent.relative_to(ROOT))
    if rel_dir == "/.":
        rel_dir = ""

    def replace_match(m):
        global count
        count += 1
        relative = m.group(2)
        # Resolve ./foo and ../foo against the page's directory
        absolute = normpath(rel_dir + "/" + relative)
        # Preserve trailing slash if original had one
        if relative.endswith("/") and not absolute.endswith("/"):
            absolute += "/"
        return m.group(1) + absolute

    new_text = PATTERN.sub(replace_match, text)
    if new_text != text:
        html_file.write_text(new_text, encoding="utf-8")
        files_changed += 1

print(f"Absolutified {count} paths in {files_changed} files")
