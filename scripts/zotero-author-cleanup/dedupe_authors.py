"""
Send batches of author name variants to Haiku to identify genuine duplicates
(same person, different name format) vs different people who share a last name.
"""

import anthropic
import json
import os
import sys
import time

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE = sys.argv[1] if len(sys.argv) > 1 else os.path.join(SCRIPT_DIR, "bad_names.txt")
OUTPUT_FILE = sys.argv[2] if len(sys.argv) > 2 else os.path.join(SCRIPT_DIR, "author_renames.txt")

client = anthropic.Anthropic()

PROMPT_TEMPLATE = """Below are groups of author names that share the same last name. For each group, identify which names are DEFINITELY the same person, just formatted differently.

ONLY merge when you are VERY confident. Apply these strict rules:

MERGE only if:
- Exact same first name, different middle initial or formatting: "John Smith" = "John B. Smith" = "John Bartholomew Smith"
- Full name matches initials exactly: "John B. Smith" = "J. B. Smith" (both initials match)
- Trivial spelling variants: "Jürgen" = "Juergen", "Léon" = "Leon", "Stanisław" = "Stanislaw"

DO NOT merge if:
- An initial is ambiguous: "J. Smith" could be John, James, Jane, etc. — do NOT merge "J. Smith" with "John Smith" unless there is a middle name/initial that confirms it
- Nicknames to full names without confirmation: do NOT merge "Andy Clark" with "Andrew G. Clark" — they could be different people
- Only last name matches with vague initials: "K. Lee" could be anyone
- Different number of initials where the existing ones don't all match

These are academic authors. Different people commonly share last names and even first initials. When in doubt, DO NOT merge.

For each group where you find definite duplicates, output:
MERGE: canonical_name <- variant1, variant2, variant3

Where canonical_name is the most complete version. Output NOTHING for groups with no certain duplicates.

Only output MERGE lines, nothing else.

Here are the groups:

{batch}"""


def parse_input(filepath):
    groups = []
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            # Format: "LastName: First1 Last1 | First2 Last2 | ..."
            parts = line.split(": ", 1)
            if len(parts) != 2:
                continue
            lastname = parts[0]
            names = [n.strip() for n in parts[1].split(" | ")]
            groups.append((lastname, names))
    return groups


def first_letter(fullname):
    """Extract first letter of the first name, uppercased. Returns '' if empty."""
    parts = fullname.strip().split()
    if not parts:
        return ""
    return parts[0][0].upper() if parts[0] else ""


def prefilter_group(names):
    """Keep only names where at least one other name shares the same first letter.
    This eliminates obvious different-people cases before sending to the LLM."""
    by_letter = {}
    for name in names:
        fl = first_letter(name)
        if fl:
            by_letter.setdefault(fl, []).append(name)
    # Only keep clusters with 2+ names sharing a first letter
    candidates = []
    for letter, cluster in by_letter.items():
        if len(cluster) >= 2:
            candidates.extend(cluster)
    return candidates


def make_batch_text(groups):
    lines = []
    for lastname, names in groups:
        lines.append(f"{lastname}: {' | '.join(names)}")
    return "\n".join(lines)


def query_haiku(batch_text):
    resp = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=4096,
        messages=[{"role": "user", "content": PROMPT_TEMPLATE.format(batch=batch_text)}],
    )
    return resp.content[0].text


def main():
    groups = parse_input(INPUT_FILE)
    print(f"Loaded {len(groups)} author groups")

    # Pre-filter: only keep groups where at least 2 names share a first letter
    filtered = []
    for lastname, names in groups:
        candidates = prefilter_group(names)
        if len(candidates) >= 2:
            filtered.append((lastname, candidates))
    print(f"After first-letter filter: {len(filtered)} groups (dropped {len(groups) - len(filtered)})")

    BATCH_SIZE = 15
    all_results = []

    for i in range(0, len(filtered), BATCH_SIZE):
        batch = filtered[i : i + BATCH_SIZE]
        batch_text = make_batch_text(batch)
        print(f"Processing batch {i // BATCH_SIZE + 1}/{(len(filtered) + BATCH_SIZE - 1) // BATCH_SIZE}...")

        result = query_haiku(batch_text)
        merge_lines = [l for l in result.strip().split("\n") if l.startswith("MERGE:")]
        all_results.extend(merge_lines)

        if i + BATCH_SIZE < len(groups):
            time.sleep(0.5)

    with open(OUTPUT_FILE, "w") as f:
        f.write("\n".join(all_results) + "\n")

    print(f"\nDone! {len(all_results)} merge suggestions written to {OUTPUT_FILE}")
    print("Review the file, then we can generate a Zotero script from it.")


if __name__ == "__main__":
    main()
