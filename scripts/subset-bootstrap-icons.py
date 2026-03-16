#!/usr/bin/env python3
"""Subset bootstrap-icons.woff to only the glyphs actually used on yuxi.ml.

Run after `quarto render` and `generate-image-variants.mjs`.

Reduces ~180KB woff + ~97KB CSS → ~2KB woff2 + ~2KB CSS.
Requires: fonttools, brotli (install via `pixi add fonttools brotli`).
"""

import re
import sys
from pathlib import Path
from fontTools.subset import main as pyftsubset_main

SITE_LIBS = Path("quarto_compiled/site_libs/bootstrap")
WOFF_FILE = SITE_LIBS / "bootstrap-icons.woff"
WOFF2_FILE = SITE_LIBS / "bootstrap-icons.woff2"
CSS_FILE = SITE_LIBS / "bootstrap-icons.css"

# Icons actually used on the site (verified by grepping compiled HTML)
KEEP_ICONS = {
    "bi-envelope":  "\\f32f",
    "bi-rss":       "\\f522",
    "bi-github":    "\\f3ed",
    "bi-twitter":   "\\f5ef",
}

# Unicode codepoints for pyftsubset
KEEP_CODEPOINTS = "U+F32F,U+F522,U+F3ED,U+F5EF"


def subset_font():
    """Subset the woff font to only the needed glyphs, output as woff2."""
    if not WOFF_FILE.exists():
        print(f"ERROR: {WOFF_FILE} not found. Run `quarto render` first.", file=sys.stderr)
        sys.exit(1)

    before = WOFF_FILE.stat().st_size

    pyftsubset_main([
        str(WOFF_FILE),
        f"--unicodes={KEEP_CODEPOINTS}",
        "--flavor=woff2",
        f"--output-file={WOFF2_FILE}",
    ])

    # Remove the old woff file
    WOFF_FILE.unlink()

    after = WOFF2_FILE.stat().st_size
    print(f"Font: {before:,}B → {after:,}B ({100 - after * 100 // before}% smaller)")


def subset_css():
    """Rewrite bootstrap-icons.css: update @font-face, keep only used icon classes."""
    if not CSS_FILE.exists():
        print(f"ERROR: {CSS_FILE} not found.", file=sys.stderr)
        sys.exit(1)

    before = CSS_FILE.stat().st_size
    css = CSS_FILE.read_text()

    # Build the new CSS from scratch: header + @font-face + base styles + kept icons
    kept_classes = []
    for name, content in KEEP_ICONS.items():
        kept_classes.append(f'.{name}::before {{ content: "{content}"; }}')

    new_css = f"""\
@font-face {{
  font-display: swap;
  font-family: "bootstrap-icons";
  src: url("./bootstrap-icons.woff2") format("woff2");
}}

.bi::before,
[class^="bi-"]::before,
[class*=" bi-"]::before {{
  display: inline-block;
  font-family: bootstrap-icons !important;
  font-style: normal;
  font-weight: normal !important;
  font-variant: normal;
  text-transform: none;
  line-height: 1;
  vertical-align: -.125em;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}}

{chr(10).join(kept_classes)}
"""

    CSS_FILE.write_text(new_css)
    after = CSS_FILE.stat().st_size
    print(f"CSS:  {before:,}B → {after:,}B ({100 - after * 100 // before}% smaller)")


def main():
    subset_font()
    subset_css()
    print("Done. bootstrap-icons subset complete.")


if __name__ == "__main__":
    main()
