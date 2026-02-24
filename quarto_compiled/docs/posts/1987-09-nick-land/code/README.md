# OCR

OCR scanned/photographed PDFs using Gemini 3 Pro's native vision API.

## Setup

```bash
conda run -n cl pip install google-genai pypdf
export GEMINI_API_KEY="your-key"   # get one at https://aistudio.google.com/apikey
```

## Usage

```bash
# Check page count
python ocr.py Land_1987.pdf --info

# Single page to stdout (good for testing)
python ocr.py Land_1987.pdf -p 1

# Page range to file
python ocr.py Land_1987.pdf -pp 1-5 -o out.txt

# Append more pages to the same file
python ocr.py Land_1987.pdf -pp 6-10 -o out.txt --append

# Whole PDF (use with care)
python ocr.py Land_1987.pdf -o out.txt
```

**Important:** use `conda activate cl` (not `conda run`) so the spinner renders live.
Alternatively: `conda run --no-capture-output -n cl python ocr.py ...`

## How it works

- Slices the PDF to the requested pages with `pypdf` (so Gemini only sees what you asked for)
- Sends the slice to `gemini-3-pro-preview` with `media_resolution: high` for maximum fidelity on pixelated text
- Uses `temperature: 0.1` for faithful transcription over creative guessing
- Large PDFs (>15 MB) automatically use the Files API upload path
- Genuinely illegible text is marked `[illegible]`

## Cost

~$2/M input tokens, ~$12/M output tokens. Each PDF page ~ 258 tokens.
A 100-page PDF costs roughly $0.05 input + output.
