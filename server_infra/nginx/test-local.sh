#!/usr/bin/env bash
set -euo pipefail
# Copies quarto_compiled to /var/www/yuxi.ml and (re)starts local nginx on port 8787.
# Usage: sudo bash server_infra/nginx/test-local.sh

CONF="$(cd "$(dirname "$0")" && pwd)/test-local.conf"
PID=/tmp/nginx-test.pid

rm -rf /var/www/yuxi.ml
cp -r "$(dirname "$0")/../../quarto_compiled" /var/www/yuxi.ml

[ -f "$PID" ] && kill "$(cat "$PID")" 2>/dev/null || true
nginx -c "$CONF"
echo "Running on http://localhost:8787"
