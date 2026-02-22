"""
Validate that all names in author_renames.txt actually appear in bad_names.txt.
Catches hallucinated canonical names and thin-space mismatches.
"""

import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
NAMES_FILE = sys.argv[1] if len(sys.argv) > 1 else os.path.join(SCRIPT_DIR, "bad_names.txt")
MERGES_FILE = sys.argv[2] if len(sys.argv) > 2 else os.path.join(SCRIPT_DIR, "author_renames.txt")

# Load all names from bad_names.txt
all_names = set()
with open(NAMES_FILE) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split(": ", 1)
        if len(parts) != 2:
            continue
        for name in parts[1].split(" | "):
            all_names.add(name.strip())

# Check each MERGE line
bad = []
good = 0
with open(MERGES_FILE) as f:
    for i, line in enumerate(f, 1):
        line = line.strip()
        if not line:
            continue
        m = re.match(r"MERGE:\s+(.+?)\s+<-\s+(.+)", line)
        if not m:
            continue
        canonical = m.group(1).strip()
        variants = [v.strip() for v in m.group(2).split(",")]

        missing = []
        if canonical not in all_names:
            missing.append(("canonical", canonical))
        for v in variants:
            if v not in all_names:
                missing.append(("variant", v))

        if missing:
            bad.append((i, line, missing))
        else:
            good += 1

print(f"{good} lines OK, {len(bad)} lines have problems:\n")
for lineno, line, missing in bad:
    print(f"Line {lineno}: {line}")
    for kind, name in missing:
        print(f'  {kind} NOT FOUND: "{name}"')
    print()
