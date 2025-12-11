#!/bin/bash
# =============================================================================
# Verify Build (Test Version)
# =============================================================================

set -euo pipefail

echo "=== Build Verification ==="

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo "[1/4] Node.js: $(node --version)"
echo "[2/4] npm: $(npm --version)"
echo "[3/4] PM2: $(pm2 --version)"

if [ -d "/var/www/backend/node_modules" ]; then
    echo "[4/4] App: OK"
    ls /var/www/backend | head -5
else
    echo "[4/4] App: MISSING node_modules!"
    exit 1
fi

echo "=== All Checks Passed ==="
