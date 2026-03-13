#!/usr/bin/env python3
"""Truncate the 'text' field in Quarto's search.json to reduce file size.

Usage: python3 scripts/truncate-search-index.py [max_chars]
Default max_chars: 1000

Reads quarto_compiled/search.json, truncates each entry's 'text' field,
and writes it back in place.
"""

import json
import sys
from pathlib import Path

MAX_CHARS = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
SEARCH_JSON = Path(__file__).resolve().parent.parent / "quarto_compiled" / "search.json"

data = json.loads(SEARCH_JSON.read_text(encoding="utf-8"))

original_size = SEARCH_JSON.stat().st_size
truncated = 0

for entry in data:
    text = entry.get("text", "")
    if len(text) > MAX_CHARS:
        entry["text"] = text[:MAX_CHARS]
        truncated += 1

output = json.dumps(data, ensure_ascii=False, separators=(",", ":"))
SEARCH_JSON.write_text(output, encoding="utf-8")

new_size = SEARCH_JSON.stat().st_size
print(f"Truncated {truncated}/{len(data)} entries to {MAX_CHARS} chars")
print(f"Size: {original_size:,} → {new_size:,} bytes ({100 * new_size / original_size:.0f}%)")
