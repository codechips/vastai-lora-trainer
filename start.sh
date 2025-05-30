#!/bin/bash
set -e

# Check for required env variables
if [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASS" ]; then
  echo "ERROR: ADMIN_USER and ADMIN_PASS must be set."
  exit 1
fi

# Generate hashed password for Caddy basic_auth
HASHED_PASS=$(caddy hash-password --plaintext "$ADMIN_PASS")

export HASHED_PASS

# Generate Caddyfile with correct template path
envsubst < /root/Caddyfile.template > /etc/caddy/Caddyfile

echo "Starting srun..."
GIN_MODE=release /opt/srun/srun -port=9001 -trusted-proxies="127.0.0.1" &

echo "Starting Filebrowser..."
filebrowser config init
filebrowser config set \
    --address=0.0.0.0 \
    --port=9002 \
    --auth.method=proxy \
    --auth.header=X-FAuth-Header \
    --root=/workspace \
    --baseurl=/files
filebrowser &

echo "Starting Caddy..."
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile --resume --environ
