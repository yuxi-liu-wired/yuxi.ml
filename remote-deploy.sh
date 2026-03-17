#!/usr/bin/env bash
set -euo pipefail

# --- Safety: only deploy from main ---
current_branch="$(git symbolic-ref --short HEAD)"
if [[ "$current_branch" != "main" ]]; then
  echo "ERROR: Deployment is only allowed from the main branch." >&2
  echo "You are on '$current_branch'. Merge into main first, then re-run." >&2
  exit 1
fi

# Ensure working tree is clean (no uncommitted changes)
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: Working tree is dirty. Commit or stash changes before deploying." >&2
  exit 1
fi

# Ensure local main is up to date with remote (push if ahead, abort if behind)
git fetch origin main
local_head="$(git rev-parse HEAD)"
remote_head="$(git rev-parse origin/main)"
if [[ "$local_head" != "$remote_head" ]]; then
  if git merge-base --is-ancestor "$remote_head" "$local_head"; then
    echo "Local is ahead of origin — pushing..."
    git push origin main
  else
    echo "ERROR: Local main has diverged from or is behind origin/main." >&2
    echo "Pull/rebase first, then re-run." >&2
    exit 1
  fi
fi

ssh yuxi-ml '~/deploy.sh'
echo "Deployed to production"
