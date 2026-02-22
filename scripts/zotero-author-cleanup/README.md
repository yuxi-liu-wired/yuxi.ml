# Zotero Author Name Cleanup

Finds duplicate author names in Zotero (same person, different formatting) and
generates a script to unify them. Uses Claude to judge which name variants refer
to the same person.

## Prerequisites

- `ANTHROPIC_API_KEY` set in environment
- `anthropic` Python package installed
- Zotero 8 with a library open

## Steps

### 1. Extract variant names from Zotero

In Zotero: **Tools > Developer > Run JavaScript**, paste and run:

```javascript
var names = {};
var items = await Zotero.Items.getAll(Zotero.Libraries.userLibraryID);
for (let item of items) {
    if (!item.isRegularItem()) continue;
    for (let c of item.getCreators()) {
        var key = c.lastName;
        var full = c.firstName + " " + c.lastName;
        if (!names[key]) names[key] = new Set();
        names[key].add(full);
    }
}
var lines = [];
for (let [last, fulls] of Object.entries(names)) {
    if (fulls.size > 1) lines.push(last + ": " + [...fulls].join(" | "));
}
return lines.join("\n");
```

Save the output to `bad_names.txt` in this directory.

### 2. Identify duplicates with Claude

```bash
python dedupe_authors.py [bad_names.txt] [author_renames.txt]
```

Sends batches to Claude Opus to identify which name variants are the same person.
Pre-filters by first letter to skip obvious non-matches. Output format:

```
MERGE: Geoffrey E. Hinton <- Geoffrey Hinton, Geoffrey E Hinton
```

### 3. Validate (optional)

```bash
python validate_merges.py [bad_names.txt] [author_renames.txt]
```

Checks that all names (canonical and variants) actually appear in `bad_names.txt`.
Catches hallucinated names. Watch for thin-space (`\u2009`) mismatches from Zotero.

### 4. Review

**Manually review `author_renames.txt`.** Delete any lines you disagree with.

### 5. Generate Zotero script

```bash
python generate_zotero_script.py [author_renames.txt] [zotero_rename_authors.js]
```

### 6. Run in Zotero

Paste the contents of `zotero_rename_authors.js` into
**Tools > Developer > Run JavaScript** and run. Reports total items updated.

## Notes

- Default model is `claude-opus-4-6`. Change in `dedupe_authors.py` if desired.
- All args are optional; scripts default to files in their own directory.
- Zotero uses thin spaces (`\u2009`) between initials — the validation script
  may flag these as mismatches even when the merge is correct.
