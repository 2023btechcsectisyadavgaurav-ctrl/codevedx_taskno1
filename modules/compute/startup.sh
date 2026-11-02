#!/bin/bash
# Startup script: installs nginx and serves a page showing which instance/zone answered.
set -euo pipefail

metadata() {
  curl -fs -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/$1"
}

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y nginx

HOSTNAME_VALUE="$(hostname)"
ZONE="$(metadata instance/zone | awk -F/ '{print $NF}')"
BUCKET="$(metadata instance/attributes/assets-bucket || echo unknown)"

cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Cloud Infrastructure Deployment</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 640px; margin: 4rem auto; padding: 0 1rem; }
    code { background: #eef; padding: .1rem .4rem; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Cloud Infrastructure Deployment</h1>
  <p>Served by instance <code>${HOSTNAME_VALUE}</code></p>
  <p>Zone: <code>${ZONE}</code></p>
  <p>Assets bucket: <code>${BUCKET}</code></p>
  <p>Refresh the page - the load balancer spreads requests across zones.</p>
</body>
</html>
EOF

# Health endpoint used by the load balancer and MIG auto-healing.
echo "ok" > /var/www/html/healthz

systemctl enable nginx
systemctl restart nginx
