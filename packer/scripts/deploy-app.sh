#!/bin/bash
# =============================================================================
# Application Deployment Script
# For Custom Base AMI with Node.js, PM2, Vault Agent, Nginx pre-installed
# Only deploys application code and installs npm dependencies
# =============================================================================

set -euo pipefail

# Configuration (from environment variables)
APP_DIRECTORY="${APP_DIRECTORY:-/var/www/backend}"
APP_USER="${APP_USER:-ubuntu}"
NVM_DIR="${NVM_DIR:-/home/ubuntu/.nvm}"

echo "============================================"
echo "Deploying Application..."
echo "============================================"

# Copy application files
echo "[1/5] Copying application files..."
if [ -d "/tmp/backend" ]; then
    cp -r /tmp/backend/* "${APP_DIRECTORY}/"
    rm -rf /tmp/backend
else
    echo "ERROR: /tmp/backend directory not found!"
    exit 1
fi

# Remove development files
echo "[2/5] Removing development files..."
rm -rf "${APP_DIRECTORY}/node_modules" 2>/dev/null || true
rm -f "${APP_DIRECTORY}/.env" 2>/dev/null || true
rm -f "${APP_DIRECTORY}/.env.local" 2>/dev/null || true
rm -rf "${APP_DIRECTORY}/.git" 2>/dev/null || true
rm -rf "${APP_DIRECTORY}/tests" 2>/dev/null || true

# Set ownership
echo "[3/5] Setting file ownership..."
chown -R "${APP_USER}:${APP_USER}" "${APP_DIRECTORY}"

# Install production dependencies
echo "[4/5] Installing production dependencies..."
sudo -u ${APP_USER} bash -c "
    export NVM_DIR=\"${NVM_DIR}\"
    [ -s \"\${NVM_DIR}/nvm.sh\" ] && . \"\${NVM_DIR}/nvm.sh\"
    
    cd ${APP_DIRECTORY}
    
    # Install only production dependencies
    npm ci --only=production --ignore-scripts
    
    # Rebuild native modules if any
    npm rebuild 2>/dev/null || true
    
    # Clear npm cache
    npm cache clean --force
"

# Set permissions
echo "[5/5] Setting file permissions..."
chmod -R 755 "${APP_DIRECTORY}"
find "${APP_DIRECTORY}" -type f -exec chmod 644 {} \;

# Create log directory
mkdir -p /var/log/app
chown -R "${APP_USER}:${APP_USER}" /var/log/app

echo "============================================"
echo "Application Deployment Complete!"
echo "Deployed to: ${APP_DIRECTORY}"
echo "============================================"
