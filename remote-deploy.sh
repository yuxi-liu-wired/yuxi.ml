#!/usr/bin/env bash
set -euo pipefail

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
