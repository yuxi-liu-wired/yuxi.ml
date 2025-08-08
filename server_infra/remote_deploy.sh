#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/yuxi-liu-wired/yuxi.ml.git"
BRANCH="main"
CHECKOUT_DIR="/opt/yuxi.ml"
STATIC_LINK="/var/www/yuxi.ml"
INIT=0
RELOAD=1

# Pick sudo only if needed and available
if [[ $EUID -eq 0 ]]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "[deploy] ERROR: Need root privileges but sudo not found." >&2
  exit 1
fi

usage() {
  echo "Usage: $0 [-i] [-n]"
  echo "  -i   initialization (create symlinks, destroy evil)"
  echo "  -n   skip nginx reload"
  exit 1
}

while getopts ":in" opt; do
  case "$opt" in
    i) INIT=1 ;;
    n) RELOAD=0 ;;
    *) usage ;;
  esac
done

log() { echo "[deploy] $*"; }

# Clone or update minimal repo
if [[ ! -d "$CHECKOUT_DIR/.git" ]]; then
  log "Cloning repo (minimal)"
  git clone --depth=1 --filter=blob:none --sparse -b "$BRANCH" "$REPO_URL" "$CHECKOUT_DIR"
  git -C "$CHECKOUT_DIR" sparse-checkout set quarto_compiled server_infra
else
  log "Updating repo"
  git -C "$CHECKOUT_DIR" sparse-checkout set quarto_compiled server_infra
  git -C "$CHECKOUT_DIR" fetch --depth=1 origin "$BRANCH"
  git -C "$CHECKOUT_DIR" reset --hard origin/"$BRANCH"
fi

chmod +x "$CHECKOUT_DIR/server_infra/remote_deploy.sh"

if (( INIT )); then
  log "Cleansing evil sites-enabled and sites-available" # https://stackoverflow.com/a/45789055/17959494
  $SUDO rm -rf /etc/nginx/sites-enabled /etc/nginx/sites-available
  $SUDO rm -f /etc/nginx/nginx.conf
  
  log "Initialization: creating symlinks"
  ln -sfn "$CHECKOUT_DIR/server_infra/remote_deploy.sh" "$HOME/deploy.sh"
  $SUDO mkdir -p "$(dirname "$STATIC_LINK")"
  $SUDO ln -sfn "$CHECKOUT_DIR/quarto_compiled" "$STATIC_LINK"

  if [[ -d "$CHECKOUT_DIR/server_infra/nginx" ]]; then
    $SUDO ln -sfn "$CHECKOUT_DIR/server_infra/nginx/nginx.conf" /etc/nginx/nginx.conf
  fi

fi

if (( RELOAD )); then
  log "Reloading nginx"
  $SUDO nginx -t && $SUDO nginx -s reload
fi

log "Done."
