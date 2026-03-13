#!/usr/bin/env bash
# Copies every index.qmd from source/ into quarto_compiled/ as index.md.
# This lets nginx serve the raw source at /path/to/page.md
# Usage: bash scripts/copy-qmd-sources.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/.."
SRC="$ROOT/source"
OUT="$ROOT/quarto_compiled"

count=0
while IFS= read -r qmd; do
  # Relative path from source dir, e.g. essays/posts/cyc/index.qmd
  rel="${qmd#$SRC/}"
  # Target: same path but .md extension
  md="${rel%.qmd}.md"
  target="$OUT/$md"
  mkdir -p "$(dirname "$target")"
  cp "$qmd" "$target"
  count=$((count + 1))
done < <(find "$SRC" -name 'index.qmd' -type f)

echo "Copied $count .qmd files as .md into quarto_compiled/"
