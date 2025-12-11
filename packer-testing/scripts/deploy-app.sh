#!/bin/bash
# =============================================================================
# Deploy Application (Test Version)
# For Custom Base AMI
# =============================================================================

set -euo pipefail

APP_DIRECTORY="${APP_DIRECTORY:-/var/www/backend}"
APP_USER="${APP_USER:-ubuntu}"
NVM_DIR="${NVM_DIR:-/home/ubuntu/.nvm}"

echo "=== Deploying Application ==="

# Copy files
echo "[1/3] Copying files..."
if [ -d "/tmp/backend" ]; then
    cp -r /tmp/backend/* "${APP_DIRECTORY}/"
    rm -rf /tmp/backend
else
    echo "ERROR: /tmp/backend not found!"
    exit 1
fi

# Set ownership
echo "[2/3] Setting ownership..."
chown -R "${APP_USER}:${APP_USER}" "${APP_DIRECTORY}"

# Install dependencies
echo "[3/3] Installing dependencies..."
sudo -u ${APP_USER} bash -c "
    export NVM_DIR=\"${NVM_DIR}\"
    [ -s \"\${NVM_DIR}/nvm.sh\" ] && . \"\${NVM_DIR}/nvm.sh\"
    cd ${APP_DIRECTORY}
    npm ci --only=production
"

echo "=== Deployment Complete ==="
