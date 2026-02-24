#!/usr/bin/env bash
# copy-md-sources.sh — Copy .qmd source files as .md into quarto_compiled/
#
# Run this after `quarto render source/` to place markdown sources alongside
# the compiled HTML. This lets LLMs (and humans) read any page in markdown
# by appending .md to the URL, à la gwern.net.
#
# What it does:
#   For each index.qmd under source/, copies it to index.md in the
#   corresponding quarto_compiled/ directory.
#
#   source/essays/posts/cyc/index.qmd → quarto_compiled/essays/posts/cyc/index.md
#
# The raw .qmd is served as-is. Quarto shortcodes and citation keys are
# readable enough for LLMs; no conversion is applied.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/source"
OUTPUT_DIR="$REPO_ROOT/quarto_compiled"

copied=0
skipped=0

while IFS= read -r -d '' qmd_file; do
    # Get path relative to source/, e.g. essays/posts/cyc/index.qmd
    rel_path="${qmd_file#"$SOURCE_DIR/"}"
    # Change extension: index.qmd → index.md
    md_rel="${rel_path%.qmd}.md"
    dest="$OUTPUT_DIR/$md_rel"

    # Only copy if the destination directory exists (i.e., Quarto actually
    # rendered this file). This avoids creating .md files for drafts or
    # files excluded from the build.
    dest_dir="$(dirname "$dest")"
    if [[ -d "$dest_dir" ]]; then
        cp "$qmd_file" "$dest"
        ((copied++))
    else
        ((skipped++))
    fi
done < <(find "$SOURCE_DIR" -name '*.qmd' -print0)

echo "copy-md-sources: copied $copied, skipped $skipped (no compiled output dir)"
