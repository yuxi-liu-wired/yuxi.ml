#!/usr/bin/env python3
"""Side-by-side PDF + OCR text viewer for proofreading."""

import argparse
import json
import mimetypes
import sys
import threading
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from urllib.parse import unquote

# ── Config ──────────────────────────────────────────────────────────────────

HOST = "127.0.0.1"
PORT = 8877


# ── HTML ────────────────────────────────────────────────────────────────────

HTML_TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>OCR Viewer</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { height: 100%; overflow: hidden;
    background: #0d0d0d; color: #d4d4d4; font-family: 'JetBrains Mono', 'Fira Code', monospace; }

  /* ── toolbar ── */
  #toolbar {
    height: 38px; display: flex; align-items: center; gap: 8px;
    padding: 0 12px; background: #161622; border-bottom: 1px solid #2a2a3a;
    font-size: 13px;
  }
  #toolbar button, #toolbar input {
    background: #1e1e2e; color: #c0c0d0; border: 1px solid #2a2a3a;
    border-radius: 4px; padding: 4px 10px; font-size: 13px; cursor: pointer;
    font-family: inherit;
  }
  #toolbar button:hover { background: #2a2a3a; }
  #toolbar .spacer { flex: 1; }
  #toolbar .page-info { color: #7a7a9a; user-select: none; }
  #page-input { width: 52px; text-align: center; }
  #save-btn { background: #1a3a2a; border-color: #2a5a3a; }
  #save-btn:hover { background: #2a5a3a; }
  #save-status { color: #5a8a5a; font-size: 12px; transition: opacity .4s; }

  /* ── split panes ── */
  #container { display: flex; height: calc(100% - 38px); }
  #pdf-pane { flex: 1; overflow: auto; display: flex; justify-content: center;
    align-items: flex-start; padding: 12px; background: #111118; }
  #pdf-pane canvas { max-width: 100%; height: auto; box-shadow: 0 0 20px rgba(0,0,0,.5); }
  #divider {
    width: 6px; cursor: col-resize; background: #1a1a2a;
    border-left: 1px solid #2a2a3a; border-right: 1px solid #2a2a3a;
    flex-shrink: 0;
  }
  #divider:hover, #divider.active { background: #3a3a5a; }
  #text-pane { flex: 1; overflow: auto; padding: 16px; }
  #text-area {
    width: 100%; min-height: 100%; background: transparent; color: #d4d4d4;
    border: none; outline: none; resize: none; font-family: inherit;
    font-size: 14px; line-height: 1.6; tab-size: 4; white-space: pre-wrap;
  }
</style>
</head>
<body>

<div id="toolbar">
  <button id="prev-btn" title="Previous page">&larr; Prev</button>
  <input id="page-input" type="text" value="1" title="Jump to page">
  <span class="page-info">/ <span id="page-count">?</span></span>
  <button id="next-btn" title="Next page">Next &rarr;</button>
  <div class="spacer"></div>
  <span id="save-status"></span>
  <button id="save-btn" title="Save edited text (Ctrl+S)">Save</button>
</div>

<div id="container">
  <div id="pdf-pane"><canvas id="pdf-canvas"></canvas></div>
  <div id="divider"></div>
  <div id="text-pane">
    <textarea id="text-area" spellcheck="false">Loading…</textarea>
  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.10.38/pdf.min.mjs" type="module"></script>
<script type="module">
  import * as pdfjsLib from 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.10.38/pdf.min.mjs';
  pdfjsLib.GlobalWorkerOptions.workerSrc =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.10.38/pdf.worker.min.mjs';

  // ── PDF rendering ──
  let pdfDoc = null, currentPage = 1;
  const canvas = document.getElementById('pdf-canvas');
  const ctx = canvas.getContext('2d');

  async function renderPage(num) {
    const page = await pdfDoc.getPage(num);
    // Render at 2× for sharpness on HiDPI
    const scale = 2;
    const vp = page.getViewport({ scale });
    canvas.width = vp.width;
    canvas.height = vp.height;
    // CSS size = half of canvas pixels → crisp on 2× screens, good on 1×
    canvas.style.width = (vp.width / scale) + 'px';
    canvas.style.height = (vp.height / scale) + 'px';
    await page.render({ canvasContext: ctx, viewport: vp }).promise;
    document.getElementById('page-input').value = num;
    currentPage = num;
  }

  const pdf = await pdfjsLib.getDocument('/pdf').promise;
  pdfDoc = pdf;
  document.getElementById('page-count').textContent = pdf.numPages;
  renderPage(1);

  // ── Navigation ──
  document.getElementById('prev-btn').addEventListener('click', () => {
    if (currentPage > 1) renderPage(currentPage - 1);
  });
  document.getElementById('next-btn').addEventListener('click', () => {
    if (currentPage < pdfDoc.numPages) renderPage(currentPage + 1);
  });
  document.getElementById('page-input').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      const n = parseInt(e.target.value, 10);
      if (n >= 1 && n <= pdfDoc.numPages) renderPage(n);
    }
  });

  // ── Load text ──
  const textArea = document.getElementById('text-area');
  const resp = await fetch('/text');
  textArea.value = await resp.text();

  // ── Save ──
  const saveStatus = document.getElementById('save-status');
  async function saveText() {
    const r = await fetch('/text', { method: 'POST', body: textArea.value });
    if (r.ok) {
      saveStatus.textContent = 'Saved';
      saveStatus.style.opacity = 1;
      setTimeout(() => { saveStatus.style.opacity = 0; }, 1500);
    } else {
      saveStatus.textContent = 'Error saving';
      saveStatus.style.opacity = 1;
    }
  }
  document.getElementById('save-btn').addEventListener('click', saveText);
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 's') { e.preventDefault(); saveText(); }
  });

  // ── Draggable divider ──
  const divider = document.getElementById('divider');
  const pdfPane = document.getElementById('pdf-pane');
  const textPane = document.getElementById('text-pane');
  let dragging = false;

  divider.addEventListener('mousedown', (e) => {
    dragging = true; divider.classList.add('active');
    e.preventDefault();
  });
  document.addEventListener('mousemove', (e) => {
    if (!dragging) return;
    const container = document.getElementById('container');
    const rect = container.getBoundingClientRect();
    const frac = (e.clientX - rect.left) / rect.width;
    const clamped = Math.max(0.15, Math.min(0.85, frac));
    pdfPane.style.flex = 'none';
    textPane.style.flex = 'none';
    pdfPane.style.width = (clamped * 100) + '%';
    textPane.style.width = ((1 - clamped) * 100 - 0.5) + '%';
  });
  document.addEventListener('mouseup', () => {
    dragging = false; divider.classList.remove('active');
  });

  // ── Keyboard page navigation (when textarea not focused) ──
  document.addEventListener('keydown', (e) => {
    if (document.activeElement === textArea) return;
    if (e.key === 'ArrowLeft' && currentPage > 1) renderPage(currentPage - 1);
    if (e.key === 'ArrowRight' && currentPage < pdfDoc.numPages) renderPage(currentPage + 1);
  });
</script>
</body>
</html>
"""


# ── Server ──────────────────────────────────────────────────────────────────

class ViewerHandler(BaseHTTPRequestHandler):
    pdf_path: Path
    txt_path: Path

    def log_message(self, fmt, *args):
        # Quieter logging — just method + path
        sys.stderr.write(f"  {args[0]}\n")

    def do_GET(self):
        path = unquote(self.path)
        if path == "/" or path == "/index.html":
            self._respond(200, "text/html", HTML_TEMPLATE.encode())
        elif path == "/pdf":
            data = self.pdf_path.read_bytes()
            self._respond(200, "application/pdf", data)
        elif path == "/text":
            data = self.txt_path.read_text(encoding="utf-8")
            self._respond(200, "text/plain; charset=utf-8", data.encode())
        else:
            self._respond(404, "text/plain", b"Not found")

    def do_POST(self):
        path = unquote(self.path)
        if path == "/text":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length).decode("utf-8")
            self.txt_path.write_text(body, encoding="utf-8")
            self._respond(200, "text/plain", b"OK")
        else:
            self._respond(404, "text/plain", b"Not found")

    def _respond(self, code, content_type, body):
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)


def main():
    parser = argparse.ArgumentParser(description="Side-by-side PDF + OCR text viewer")
    parser.add_argument("pdf", type=Path, help="Path to the PDF file")
    parser.add_argument("txt", type=Path, help="Path to the OCR text file")
    parser.add_argument("-p", "--port", type=int, default=PORT, help=f"Port (default {PORT})")
    args = parser.parse_args()

    if not args.pdf.exists():
        sys.exit(f"PDF not found: {args.pdf}")
    if not args.txt.exists():
        sys.exit(f"Text file not found: {args.txt}")

    ViewerHandler.pdf_path = args.pdf.resolve()
    ViewerHandler.txt_path = args.txt.resolve()

    server = HTTPServer((HOST, args.port), ViewerHandler)
    url = f"http://{HOST}:{args.port}"
    print(f"Serving at {url}")
    print(f"  PDF:  {args.pdf}")
    print(f"  Text: {args.txt}")
    print("Press Ctrl+C to stop.\n")

    threading.Timer(0.5, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
        server.server_close()


if __name__ == "__main__":
    main()
