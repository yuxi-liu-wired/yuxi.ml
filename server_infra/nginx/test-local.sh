#!/usr/bin/env bash
set -euo pipefail
# Sets up /tmp/www/yuxi.ml from quarto_compiled and runs the test suite.
# Usage: bash server_infra/nginx/test-local.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Copy web root
rm -rf /tmp/www/yuxi.ml
mkdir -p /tmp/www
cp -r "$ROOT/quarto_compiled" /tmp/www/yuxi.ml

# Run tests
bash "$SCRIPT_DIR/test-nginx.sh"
