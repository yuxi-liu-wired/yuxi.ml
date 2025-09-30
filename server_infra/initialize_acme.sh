#!/usr/bin/env bash
set -euo pipefail

echo "Initializing nginx configuration"
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --upgrade --auto-upgrade
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# ensure webroot exists and is served by your 80 server's ACME location
install -d -m 755 /var/www/html

# first issue for both apex and www using HTTP-01
~/.acme.sh/acme.sh --issue \
  -d yuxi.ml -d www.yuxi.ml \
  -w /var/www/html

# install certs to the paths nginx already uses and set reload on renew
install -d -m 700 /etc/nginx/ssl
~/.acme.sh/acme.sh --install-cert -d yuxi.ml \
  --key-file       /etc/nginx/ssl/yuxi.ml.key \
  --fullchain-file /etc/nginx/ssl/yuxi.ml.crt \
  --reloadcmd      "nginx -s reload"

# tighten permissions
chown root:root /etc/nginx/ssl
chmod 755 /etc/nginx/ssl        # allow traversal
chmod 600 /etc/nginx/ssl/yuxi.ml.key
chmod 644 /etc/nginx/ssl/yuxi.ml.crt
echo "ACME initialization complete"