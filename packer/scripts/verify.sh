#!/bin/bash
# =============================================================================
# Verification Script
# Verifies the build completed successfully
# =============================================================================

set -euo pipefail

echo "============================================"
echo "Build Verification"
echo "============================================"

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Check Node.js
echo "[1/6] Checking Node.js..."
if command -v node &>/dev/null; then
    echo "  ✓ Node.js: $(node --version)"
else
    echo "  ✗ Node.js: NOT FOUND"
    exit 1
fi

# Check npm
echo "[2/6] Checking npm..."
if command -v npm &>/dev/null; then
    echo "  ✓ npm: $(npm --version)"
else
    echo "  ✗ npm: NOT FOUND"
    exit 1
fi

# Check PM2
echo "[3/6] Checking PM2..."
if command -v pm2 &>/dev/null; then
    echo "  ✓ PM2: $(pm2 --version)"
else
    echo "  ✗ PM2: NOT FOUND"
    exit 1
fi

# Check application directory
echo "[4/6] Checking application..."
if [ -d "/var/www/backend" ]; then
    echo "  ✓ App directory: /var/www/backend"
    echo "  Files:"
    ls -la /var/www/backend | head -8 | sed 's/^/    /'
else
    echo "  ✗ App directory: NOT FOUND"
    exit 1
fi

# Check node_modules
echo "[5/6] Checking dependencies..."
if [ -d "/var/www/backend/node_modules" ]; then
    echo "  ✓ node_modules: installed"
else
    echo "  ✗ node_modules: NOT FOUND"
    exit 1
fi

# Check ecosystem.config.js
echo "[6/6] Checking PM2 config..."
if [ -f "/var/www/backend/ecosystem.config.js" ]; then
    echo "  ✓ ecosystem.config.js: exists"
else
    echo "  ✗ ecosystem.config.js: NOT FOUND"
    exit 1
fi

echo ""
echo "============================================"
echo "All Checks Passed! ✓"
echo "============================================"
