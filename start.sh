#!/bin/bash
set -e

# Check for required env variables
if [ -z "$CADDY_ADMIN_USER" ] || [ -z "$CADDY_ADMIN_PASS" ]; then
  echo "ERROR: CADDY_ADMIN_USER and CADDY_ADMIN_PASS must be set."
  exit 1
fi

# Generate hashed password for Caddy basic_auth
HASHED_PASS=$(caddy hash-password --plaintext "$CADDY_ADMIN_PASS")

export HASHED_PASS

# Generate final Caddyfile from the template
envsubst </Caddyfile.template >/etc/caddy/Caddyfile

echo "Starting srun..."
GIN_MODE=release /opt/srun/srun -port 9001 &

echo "Starting Filebrowser..."
filebrowser -r /data -p 9002 &

pip3 install flask
python3 /opt/login/app.py &

echo "Starting Caddy..."
# exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile --resume --environ
