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

# ── Setup ────────────────────────────────────────────────────────

echo "=== Nginx Test Suite ==="
echo ""

# Copy web root if needed
if [[ ! -d /tmp/www/yuxi.ml ]]; then
  echo "Copying quarto_compiled → /tmp/www/yuxi.ml ..."
  mkdir -p /tmp/www
  cp -r /workspace/yuxi.ml/quarto_compiled /tmp/www/yuxi.ml
fi

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
echo "--- sub_filter: relative → absolute paths ---"
check_body     "/cyc rewrites figure src"     "/cyc" 'src="/cyc/figure/'
check_body_not "/cyc no bare figure src"      "/cyc" 'src="figure/'

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
echo "--- 404 handling ---"
check_status "nonexistent path → 404"                           "/this-does-not-exist"              "404"

echo ""
echo "==========================================="
if [[ $FAIL -eq 0 ]]; then
  echo "$(green "All $PASS tests passed!")"
else
  echo "$(red "$FAIL failed"), $PASS passed out of $TOTAL"
fi
echo "==========================================="

# ── Teardown ─────────────────────────────────────────────────────
nginx -s stop -c "$CONF" 2>/dev/null || true

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
