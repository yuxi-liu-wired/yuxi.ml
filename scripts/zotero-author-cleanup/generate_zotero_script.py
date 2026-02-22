"""
Read author_renames.txt and generate a Zotero JavaScript script
that renames all variants to their canonical names.
"""

import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(SCRIPT_DIR, "author_renames.txt")
OUTPUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(SCRIPT_DIR, "zotero_rename_authors.js")

TEMPLATE = '''
// {canonical} <- {variants_str}
{{
    var oldNames = {old_names_js};
    var newFirstName = {new_first_js};
    var newLastName = {new_last_js};
    for (let oldName of oldNames) {{
        var s = new Zotero.Search();
        s.libraryID = ZoteroPane.getSelectedLibraryID();
        s.addCondition('creator', 'is', oldName);
        var ids = await s.search();
        if (!ids.length) continue;
        await Zotero.DB.executeTransaction(async function () {{
            for (let id of ids) {{
                let item = await Zotero.Items.getAsync(id);
                let creators = item.getCreators();
                let newCreators = [];
                for (let creator of creators) {{
                    if (`${{creator.firstName}} ${{creator.lastName}}`.trim() == oldName) {{
                        creator.firstName = newFirstName;
                        creator.lastName = newLastName;
                        creator.fieldMode = 0;
                    }}
                    newCreators.push(creator);
                }}
                item.setCreators(newCreators);
                await item.save();
            }}
        }});
        count += ids.length;
    }}
}}
'''

def split_name(fullname):
    """Split 'Douglas B. Lenat' into ('Douglas B.', 'Lenat')"""
    parts = fullname.strip().rsplit(" ", 1)
    if len(parts) == 1:
        return ("", parts[0])
    return (parts[0], parts[1])


def js_string(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'


def main():
    # Deduplicate: same canonical can appear multiple times
    seen = {}
    with open(INPUT) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            m = re.match(r"MERGE:\s+(.+?)\s+<-\s+(.+)", line)
            if not m:
                continue
            canonical = m.group(1).strip()
            variants = [v.strip() for v in m.group(2).split(",")]
            if canonical not in seen:
                seen[canonical] = set()
            seen[canonical].update(variants)

    blocks = []
    blocks.append("var count = 0;")

    for canonical, variants in seen.items():
        # Remove canonical from variants if it appears there (self-reference)
        variants.discard(canonical)
        if not variants:
            continue

        first, last = split_name(canonical)
        old_names_js = "[" + ", ".join(js_string(v) for v in sorted(variants)) + "]"
        block = TEMPLATE.format(
            canonical=canonical,
            variants_str=", ".join(sorted(variants)),
            old_names_js=old_names_js,
            new_first_js=js_string(first),
            new_last_js=js_string(last),
        )
        blocks.append(block)

    blocks.append('return count + " item(s) updated in total";')

    with open(OUTPUT, "w") as f:
        f.write("\n".join(blocks))

    print(f"Generated {len(seen)} rename blocks -> {OUTPUT}")


if __name__ == "__main__":
    main()
