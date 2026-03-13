#!/usr/bin/env bash
# test-nginx.sh — Regression test suite for nginx config
# Usage: bash server_infra/nginx/test-nginx.sh
#
# Starts local nginx on :8080, runs tests, stops nginx.
# Requires: quarto_compiled already copied to /tmp/www/yuxi.ml

set -uo pipefail

PORT=8080
BASE="http://localhost:$PORT"
CONF="/workspace/yuxi.ml/server_infra/nginx/test-local.conf"
PID_FILE="/tmp/nginx-test.pid"
PASS=0
FAIL=0
TOTAL=0

# ── Helpers ──────────────────────────────────────────────────────

red()   { printf '\033[31m%s\033[0m' "$1"; }
green() { printf '\033[32m%s\033[0m' "$1"; }

check_status() {
  local desc="$1" url="$2" expected_status="$3" expected_location="${4:-}"
  ((TOTAL++))

  local headers status location
  headers=$(curl -sI -o /dev/null -w '%{http_code} %{redirect_url}' "$BASE$url" 2>/dev/null)
  status=$(echo "$headers" | awk '{print $1}')
  # Get Location header directly for relative URLs
  location=$(curl -sI "$BASE$url" 2>/dev/null | grep -i '^location:' | sed 's/^[Ll]ocation: *//;s/\r//;s/ *$//')

  local ok=true
  if [[ "$status" != "$expected_status" ]]; then
    ok=false
  fi
  if [[ -n "$expected_location" ]]; then
    # Location might be relative (/cyc) or absolute (http://localhost:8080/cyc)
    local loc_path="$location"
    loc_path="${loc_path#http://localhost:$PORT}"
    if [[ "$loc_path" != "$expected_location" ]]; then
      ok=false
    fi
  fi

  if $ok; then
    echo "  $(green PASS): $desc"
    ((PASS++))
  else
    echo "  $(red FAIL): $desc"
    echo "    URL:      $url"
    echo "    Expected: $expected_status ${expected_location:+→ $expected_location}"
    echo "    Got:      $status ${location:+→ $location}"
    ((FAIL++))
  fi
}

check_body() {
  local desc="$1" url="$2" expected_string="$3"
  ((TOTAL++))

  local tmpf="/tmp/nginx-test-body.$$"
  curl -s "$BASE$url" -o "$tmpf" 2>/dev/null
  if grep -qF "$expected_string" "$tmpf" 2>/dev/null; then
    echo "  $(green PASS): $desc"
    ((PASS++))
  else
    echo "  $(red FAIL): $desc"
    echo "    URL: $url"
    echo "    Expected body to contain: $expected_string"
    ((FAIL++))
  fi
  rm -f "$tmpf"
}

check_body_not() {
  local desc="$1" url="$2" unexpected_string="$3"
  ((TOTAL++))

  local tmpf="/tmp/nginx-test-body.$$"
  curl -s "$BASE$url" -o "$tmpf" 2>/dev/null
  if ! grep -qF "$unexpected_string" "$tmpf" 2>/dev/null; then
    echo "  $(green PASS): $desc"
    ((PASS++))
  else
    echo "  $(red FAIL): $desc"
    echo "    URL: $url"
    echo "    Expected body NOT to contain: $unexpected_string"
    ((FAIL++))
  fi
  rm -f "$tmpf"
}

check_content_type() {
  local desc="$1" url="$2" expected_type="$3"
  ((TOTAL++))

  local ct
  ct=$(curl -sI "$BASE$url" 2>/dev/null | grep -i '^content-type:' | sed 's/^[Cc]ontent-[Tt]ype: *//;s/;.*//;s/\r//;s/ *$//')
  if [[ "$ct" == "$expected_type" ]]; then
    echo "  $(green PASS): $desc"
    ((PASS++))
  else
    echo "  $(red FAIL): $desc"
    echo "    URL: $url"
    echo "    Expected content-type: $expected_type"
    echo "    Got: $ct"
    ((FAIL++))
  fi
}

# ── Setup ────────────────────────────────────────────────────────

echo "=== Nginx Test Suite ==="
echo ""

# Copy web root if needed
if [[ ! -d /tmp/www/yuxi.ml ]]; then
  echo "Copying quarto_compiled → /tmp/www/yuxi.ml ..."
  mkdir -p /tmp/www
  cp -r /workspace/yuxi.ml/quarto_compiled /tmp/www/yuxi.ml
fi

# Validate config syntax first
echo "--- nginx -t (config validation) ---"
if nginx -t -c "$CONF" 2>&1 | grep -q "test is successful"; then
  echo "  $(green PASS): config syntax valid"
else
  echo "  $(red FAIL): config syntax invalid"
  nginx -t -c "$CONF" 2>&1
  exit 1
fi
echo ""

# Stop any existing test nginx
if [[ -f "$PID_FILE" ]]; then
  kill "$(cat "$PID_FILE")" 2>/dev/null || true
  sleep 0.3
fi

# Start nginx
nginx -c "$CONF" 2>/dev/null
sleep 0.3

if ! curl -s "$BASE" >/dev/null 2>&1; then
  echo "ERROR: nginx failed to start. Check /tmp/nginx-test-error.log"
  cat /tmp/nginx-test-error.log
  exit 1
fi
echo "nginx running on :$PORT"
echo ""

# ── Tests ────────────────────────────────────────────────────────

echo "--- Vanity URL: /cyc ---"
check_status "/cyc serves 200"                                  "/cyc"                              "200"
check_status "/cyc/ → /cyc"                                     "/cyc/"                             "301" "/cyc"
check_status "/essays/posts/cyc/index.html → /cyc"              "/essays/posts/cyc/index.html"      "301" "/cyc"
check_status "/essays/posts/cyc/ → /cyc"                        "/essays/posts/cyc/"                "301" "/cyc"
check_status "/essays/posts/cyc → /cyc"                         "/essays/posts/cyc"                 "301" "/cyc"

echo ""
echo "--- Sub-resources under /cyc ---"
check_status "/cyc/figure/AM_ontology.png"                      "/cyc/figure/AM_ontology.png"       "200"
check_status "/cyc/figure/Eurisko_GUI.png"                      "/cyc/figure/Eurisko_GUI.png"       "200"
check_status "/cyc/figure/Cyc_progress_history.svg"             "/cyc/figure/Cyc_progress_history.svg" "200"
check_status "/cyc/figure/opencyc-kb-browser.gif"               "/cyc/figure/opencyc-kb-browser.gif"   "200"
check_status "/cyc/figure/Vauquois%20triangle.png"              "/cyc/figure/Vauquois%20triangle.png"  "200"

echo ""
echo "--- Trailing slash stripping ---"
check_status "/about/ → /about"                                 "/about/"                           "301" "/about"
check_status "/essays/ → /essays"                               "/essays/"                          "301" "/essays"
check_status "/docs/ → /docs"                                   "/docs/"                            "301" "/docs"

echo ""
echo "--- index.html stripping ---"
check_status "/about/index.html → /about"                       "/about/index.html"                 "301" "/about"
check_status "/essays/index.html → /essays"                     "/essays/index.html"                "301" "/essays"

echo ""
echo "--- Normal page serving ---"
check_status "/ serves 200"                                     "/"                                 "200"
check_status "/about serves 200"                                "/about"                            "200"
check_status "/essays serves 200"                               "/essays"                           "200"

echo ""
echo "--- Query string preservation ---"
check_status "/essays/posts/cyc/index.html?q=foo → /cyc?q=foo" "/essays/posts/cyc/index.html?q=foo" "301" "/cyc?q=foo"

echo ""
echo "--- .md source serving ---"
check_status "/cyc.md serves 200"                               "/cyc.md"                           "200"
check_body   "/cyc.md contains qmd frontmatter"                 "/cyc.md"                           "title: \"Cyc\""
check_content_type "/cyc.md is text/plain"                      "/cyc.md"                           "text/plain"

echo ""
echo "--- Code directory: no 403 ---"
check_status "/docs/posts/1987-09-nick-land/code → not 403"    "/docs/posts/1987-09-nick-land/code"  "404"
check_status "/docs/posts/1987-09-nick-land/code/ocr.py → 200" "/docs/posts/1987-09-nick-land/code/ocr.py" "200"

echo ""
echo "--- 404 handling ---"
check_status "nonexistent path → 404"                           "/this-does-not-exist"              "404"

echo ""
echo "--- All pages servable (every index.html in web root) ---"
check_all_pages() {
  local root="/tmp/www/yuxi.ml"
  local crawl_total=0
  local crawl_fail=0
  local failed_urls=""

  while IFS= read -r html_file; do
    local url_path="${html_file#$root}"
    url_path="${url_path%/index.html}"
    [[ -z "$url_path" ]] && url_path="/"

    local status
    status=$(curl -sI -o /dev/null -w '%{http_code}' "$BASE$url_path" 2>/dev/null)
    crawl_total=$((crawl_total + 1))

    if [[ "$status" == "404" || "$status" == "403" || "$status" == "500" ]]; then
      crawl_fail=$((crawl_fail + 1))
      failed_urls="$failed_urls\n    $status $url_path"
    fi
  done < <(find "$root" -name 'index.html' -type f | sort)

  ((TOTAL++))

  if [[ $crawl_fail -eq 0 ]]; then
    echo "  $(green PASS): all $crawl_total pages serve OK"
    ((PASS++))
  else
    echo "  $(red FAIL): $crawl_fail/$crawl_total pages broken"
    echo -e "$failed_urls"
    ((FAIL++))
  fi
}
check_all_pages

echo ""
echo "--- No broken assets (crawl every page, resolve every src/href) ---"
check_all_assets() {
  local root="/tmp/www/yuxi.ml"
  local asset_total=0
  local asset_fail=0
  local failed_assets=""
  local refs_file="/tmp/nginx-test-refs.$$"

  while IFS= read -r html_file; do
    # Page URL as browser sees it (no trailing slash, no index.html)
    local page_url="${html_file#$root}"
    page_url="${page_url%/index.html}"
    [[ -z "$page_url" ]] && page_url="/"

    # Fetch the page as nginx serves it
    local tmpf="/tmp/nginx-test-assets.$$"
    curl -s "$BASE$page_url" -o "$tmpf" 2>/dev/null

    # Extract src="..." and href="..." values, filter out non-asset refs
    grep -oP '(?:src|href)="\K[^"]+' "$tmpf" 2>/dev/null | \
      grep -v '^#' | grep -v '^mailto:' | grep -v '^javascript:' | \
      grep -v '^https\?://' | grep -v '^data:' | \
      sort -u > "$refs_file" 2>/dev/null

    while IFS= read -r ref; do
      # Resolve relative URL the way a browser does
      local resolved=""
      if [[ "$ref" == /* ]]; then
        resolved="$ref"
      elif [[ "$page_url" == "/" ]]; then
        resolved="/$ref"
      else
        # Browser base dir is parent of the URL path (no trailing slash)
        local base_dir="${page_url%/*}"
        [[ -z "$base_dir" ]] && base_dir=""

        local remaining="$ref"
        local base="$base_dir"
        while [[ "$remaining" == ../* ]]; do
          remaining="${remaining#../}"
          base="${base%/*}"
        done
        resolved="$base/$remaining"
      fi

      [[ -z "$resolved" ]] && continue
      resolved="${resolved%%#*}"
      local check_url="${resolved%%\?*}"
      [[ -z "$check_url" ]] && continue

      local status
      status=$(curl -sI -o /dev/null -w '%{http_code}' "$BASE$check_url" 2>/dev/null)
      asset_total=$((asset_total + 1))

      if [[ "$status" == "404" || "$status" == "403" || "$status" == "500" ]]; then
        asset_fail=$((asset_fail + 1))
        failed_assets="$failed_assets\n    $status $check_url (from $page_url, ref=$ref)"
      fi
    done < "$refs_file"

    rm -f "$tmpf" "$refs_file"
  done < <(find "$root" -name 'index.html' -type f | sort)

  ((TOTAL++))

  if [[ $asset_fail -eq 0 ]]; then
    echo "  $(green PASS): all $asset_total assets serve OK"
    ((PASS++))
  else
    echo "  $(red FAIL): $asset_fail/$asset_total assets broken"
    echo -e "$failed_assets"
    ((FAIL++))
  fi
}
check_all_assets

echo ""
echo "==========================================="
if [[ $FAIL -eq 0 ]]; then
  echo "$(green "All $PASS tests passed!")"
else
  echo "$(red "$FAIL failed"), $PASS passed out of $TOTAL"
fi
echo "==========================================="

# ── Teardown ─────────────────────────────────────────────────────
# Leave nginx running for manual inspection (on port 8080)
if [[ $FAIL -eq 0 ]]; then
  echo ""
  echo "nginx left running on :$PORT for manual inspection."
  echo "Stop with: nginx -s stop -c $CONF"
fi

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
