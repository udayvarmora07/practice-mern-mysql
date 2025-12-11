#!/bin/bash
# =============================================================================
# Cleanup Script
# Cleans up temporary files before AMI creation
# =============================================================================

set -euo pipefail

echo "============================================"
echo "Pre-AMI Cleanup"
echo "============================================"

# Clean apt cache
echo "[1/6] Cleaning apt cache..."
apt-get clean 2>/dev/null || true
rm -rf /var/lib/apt/lists/* 2>/dev/null || true

# Clean npm cache
echo "[2/6] Cleaning npm cache..."
rm -rf /home/ubuntu/.npm/_cacache 2>/dev/null || true

# Remove temporary files
echo "[3/6] Removing temporary files..."
rm -rf /tmp/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true

# Truncate log files
echo "[4/6] Cleaning log files..."
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
find /var/log -type f -name "*.gz" -delete 2>/dev/null || true

# Clean bash history
echo "[5/6] Cleaning shell history..."
rm -f /root/.bash_history 2>/dev/null || true
rm -f /home/ubuntu/.bash_history 2>/dev/null || true

# Sync filesystem
echo "[6/6] Syncing filesystem..."
sync

echo "============================================"
echo "Cleanup Complete!"
echo "============================================"
