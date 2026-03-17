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

# Ensure local main is up to date with remote
git fetch origin main
local_head="$(git rev-parse HEAD)"
remote_head="$(git rev-parse origin/main)"
if [[ "$local_head" != "$remote_head" ]]; then
  echo "WARNING: Local main ($local_head) differs from origin/main ($remote_head)." >&2
  echo "Push or pull first, then re-run." >&2
  exit 1
fi

tag="deploy-$(date +%Y-%m-%d)"
# Append .N if tag already exists today
n=1
while git tag -l "$tag" | grep -q .; do
  tag="deploy-$(date +%Y-%m-%d).$n"
  n=$((n + 1))
done

git tag "$tag"
echo "Tagged: $tag"

git push origin main --tags
echo "Pushed to GitHub"

ssh yuxi-ml '~/deploy.sh'
echo "Deployed to production"
