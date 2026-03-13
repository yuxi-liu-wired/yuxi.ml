#!/usr/bin/env python3
"""Convert relative figure/ and code/ paths to absolute paths in HTML files.

Without trailing slashes, browsers resolve relative URLs against the parent
directory, breaking src="figure/foo.png" on pages like /essays/posts/foo.
This script rewrites them to absolute paths based on each file's location.

Usage: python3 scripts/absolutify-figure-paths.py
"""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "quarto_compiled"

# Patterns: src="figure/..." or href="figure/..." (and code/)
PATTERN = re.compile(r'((?:src|href)=")(figure/|code/)')

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
        # e.g. src="figure/ → src="/essays/posts/cyc/figure/
        return m.group(1) + rel_dir + "/" + m.group(2)

    new_text = PATTERN.sub(replace_match, text)
    if new_text != text:
        html_file.write_text(new_text, encoding="utf-8")
        files_changed += 1

print(f"Absolutified {count} paths in {files_changed} files")
