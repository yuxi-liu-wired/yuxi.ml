#!/usr/bin/env python3
"""
OCR a PDF using Gemini 3 Pro's native vision.

Examples:
    python ocr.py Land_1987.pdf --page 1          # just page 1, prints to stdout
    python ocr.py Land_1987.pdf --pages 1-5        # pages 1 through 5
    python ocr.py Land_1987.pdf --pages 1-5 -o out.txt
    python ocr.py Land_1987.pdf --pages 6-10 -o out.txt --append
    python ocr.py Land_1987.pdf                    # whole PDF (you probably don't want this)

Requires:
    pip install google-genai pypdf

Set your API key:
    export GEMINI_API_KEY="your-key-here"
"""

import argparse
import io
import os
import pathlib
import sys
import threading
import time

from google import genai
from google.genai import types
from pypdf import PdfReader, PdfWriter


class Spinner:
    """Elapsed-time spinner so you know it's not dead."""
    def __init__(self, prefix=""):
        self._prefix = prefix
        self._stop = threading.Event()
        self._thread = None

    def __enter__(self):
        self._stop.clear()
        self._thread = threading.Thread(target=self._spin, daemon=True)
        self._thread.start()
        return self

    def __exit__(self, *_):
        self._stop.set()
        self._thread.join()
        sys.stderr.write("\r\033[K")  # clear spinner line
        sys.stderr.flush()

    def _spin(self):
        chars = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        t0 = time.time()
        i = 0
        while not self._stop.wait(0.15):
            elapsed = time.time() - t0
            sys.stderr.write(f"\r  {chars[i % len(chars)]} {self._prefix} ({elapsed:.0f}s)")
            sys.stderr.flush()
            i += 1


def make_client():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set.", file=sys.stderr)
        print("Get one at: https://aistudio.google.com/apikey", file=sys.stderr)
        sys.exit(1)
    return genai.Client(api_key=api_key)


def slice_pdf(pdf_path: pathlib.Path, start: int, end: int) -> bytes:
    """Extract pages [start, end] (1-indexed) from a PDF and return as bytes."""
    reader = PdfReader(pdf_path)
    total = len(reader.pages)
    if start < 1 or end > total or start > end:
        print(f"Error: invalid page range {start}-{end} (PDF has {total} pages).", file=sys.stderr)
        sys.exit(1)
    writer = PdfWriter()
    for i in range(start - 1, end):  # 0-indexed internally
        writer.add_page(reader.pages[i])
    buf = io.BytesIO()
    writer.write(buf)
    return buf.getvalue()


def pdf_page_count(pdf_path: pathlib.Path) -> int:
    return len(PdfReader(pdf_path).pages)


def ocr_pdf(client, pdf_bytes: bytes, page_label: str):
    """Send PDF bytes to Gemini 3 Pro and extract all text."""
    file_size_mb = len(pdf_bytes) / (1024 * 1024)

    if file_size_mb > 15:
        print(f"  {page_label}: {file_size_mb:.1f} MB — uploading via Files API...")
        buf = io.BytesIO(pdf_bytes)
        uploaded = client.files.upload(
            file=buf,
            config={"mime_type": "application/pdf"},
        )
        doc_part = uploaded
    else:
        doc_part = types.Part.from_bytes(
            data=pdf_bytes,
            mime_type="application/pdf",
            media_resolution={"level": "media_resolution_high"},
        )

    prompt = (
        "Extract ALL text from this scanned document. "
        "Preserve the original layout, paragraph breaks, and reading order as closely as possible. "
        "If text is unclear or pixelated, use surrounding context to infer the most likely reading. "
        "If text is underlined in the original text, use <u>...</u> tag-brackets in the transcription."
        "If text is a block quote, use <blockquote> tag-bracket in the transcription."
        "Mark genuinely illegible portions with [illegible]. "
        "Output only the extracted text, no commentary."
    )

    t0 = time.time()
    with Spinner(f"{page_label}: waiting for Gemini 3 Pro"):
        response = client.models.generate_content(
            model="gemini-3-pro-preview",
            contents=[doc_part, prompt],
            config=types.GenerateContentConfig(
                temperature=0.1,
                max_output_tokens=65536,
            ),
        )

    elapsed = time.time() - t0
    token_info = ""
    if response.usage_metadata:
        m = response.usage_metadata
        token_info = f", tokens: {m.prompt_token_count} in / {m.candidates_token_count} out"
    print(f"  {page_label}: done in {elapsed:.1f}s{token_info}")

    if response.text is None:
        # Gemini returned no content — safety filter, overload, or empty response
        finish = None
        if response.candidates:
            finish = response.candidates[0].finish_reason
        raise RuntimeError(
            f"{page_label}: Gemini returned no text (finish_reason={finish}). "
            f"Try a smaller page range."
        )
    return response.text


def parse_page_range(s: str) -> tuple[int, int]:
    parts = s.split("-")
    if len(parts) != 2:
        raise argparse.ArgumentTypeError(f"Expected START-END, got: {s}")
    try:
        return (int(parts[0]), int(parts[1]))
    except ValueError:
        raise argparse.ArgumentTypeError(f"Expected integers, got: {s}")


def main():
    parser = argparse.ArgumentParser(
        description="OCR a PDF using Gemini 3 Pro",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "examples:\n"
            "  %(prog)s Land_1987.pdf --page 1\n"
            "  %(prog)s Land_1987.pdf --pages 3-7 -o out.txt\n"
            "  %(prog)s Land_1987.pdf --pages 8-12 -o out.txt --append\n"
            "  %(prog)s Land_1987.pdf --info\n"
        ),
    )
    parser.add_argument("pdf", nargs="?", type=pathlib.Path, help="path to the PDF file")
    parser.add_argument("-p", "--page", type=int, help="extract a single page")
    parser.add_argument("-pp", "--pages", type=parse_page_range, metavar="START-END",
                        help="extract a range of pages (Starts with 1, inclusive)")
    parser.add_argument("-o", "--output", type=pathlib.Path,
                        help="output file (default: stdout)")
    parser.add_argument("--append", action="store_true",
                        help="append to output file instead of overwriting")
    parser.add_argument("--chunk", type=int, default=20, metavar="N",
                        help="max pages per API call (default: 20)")
    parser.add_argument("--info", action="store_true",
                        help="just print PDF page count and exit")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    if args.pdf is None:
        parser.print_help()
        sys.exit(0)

    if not args.pdf.exists():
        print(f"Error: {args.pdf} not found.", file=sys.stderr)
        sys.exit(1)

    # --info: just show page count
    if args.info:
        count = pdf_page_count(args.pdf)
        print(f"{args.pdf}: {count} pages")
        return

    # Resolve page range
    if args.page and args.pages:
        print("Error: use --page or --pages, not both.", file=sys.stderr)
        sys.exit(1)

    if args.page:
        page_range = (args.page, args.page)
    elif args.pages:
        page_range = args.pages
    else:
        page_range = None

    # Slice or use whole PDF
    if page_range:
        start, end = page_range
        label = f"p{start}" if start == end else f"p{start}-{end}"
        pdf_bytes = slice_pdf(args.pdf, start, end)
    else:
        total = pdf_page_count(args.pdf)
        label = f"p1-{total} (all)"
        print(f"Processing entire PDF ({total} pages). Consider --pages for a test run first.")
        pdf_bytes = args.pdf.read_bytes()

    # Default output filename: Land_1987_p21-100.txt or Land_1987.txt
    if args.output is None and not sys.stdout.isatty():
        pass  # piped — leave as stdout
    elif args.output is None:
        stem = args.pdf.stem
        suffix = f"_{label.split(' ')[0]}" if page_range else ""
        args.output = pathlib.Path(f"{stem}{suffix}.txt")
        print(f"  output: {args.output}")

    client = make_client()

    # Chunk large ranges into smaller API calls
    if page_range:
        start, end = page_range
        chunk_size = args.chunk
        chunks = []
        for cs in range(start, end + 1, chunk_size):
            ce = min(cs + chunk_size - 1, end)
            chunks.append((cs, ce))
    else:
        chunks = [(1, pdf_page_count(args.pdf))]

    if len(chunks) > 1:
        print(f"  splitting into {len(chunks)} chunks of up to {args.chunk} pages")

    results = []
    for cs, ce in chunks:
        clabel = f"p{cs}" if cs == ce else f"p{cs}-{ce}"
        chunk_bytes = slice_pdf(args.pdf, cs, ce) if len(chunks) > 1 else pdf_bytes
        try:
            text = ocr_pdf(client, chunk_bytes, clabel)
            results.append(text)
        except RuntimeError as e:
            print(f"  ERROR: {e}", file=sys.stderr)
            print(f"  partial results so far: {len(results)} chunk(s)", file=sys.stderr)
            if results and args.output:
                # Save what we have
                _write_output(args, "\n\n".join(results), partial=True)
            sys.exit(1)

    full_text = "\n\n".join(results)

    # Output
    _write_output(args, full_text)


def _write_output(args, text, partial=False):
    tag = " (PARTIAL)" if partial else ""
    if args.output:
        mode = "a" if args.append else "w"
        with open(args.output, mode, encoding="utf-8") as f:
            if args.append:
                f.write("\n\n")
            f.write(text)
        action = "appended to" if args.append else "written to"
        print(f"  {action}{tag} {args.output}")
    else:
        print()
        print(text)


if __name__ == "__main__":
    main()
