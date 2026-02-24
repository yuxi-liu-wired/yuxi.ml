# OCR project

## What this is
Script to OCR scanned/photographed PDFs using Gemini 3 Pro vision API.

## Key files
- `ocr.py` — main script, self-contained
- `Land_1987.pdf` — the source PDF being OCR'd

## Environment
- Conda env: `cl`
- Deps: `google-genai`, `pypdf`
- API key: `GEMINI_API_KEY` env var

## Gotchas
- `conda run` buffers all output — spinner won't render live. Use `conda activate cl` or `conda run --no-capture-output`.
- The `-pp` flag (page range) actually slices the PDF with pypdf before sending, so Gemini only sees the requested pages.
- Large PDFs (>15 MB) automatically switch to the Files API upload path.
