#!/bin/bash
# =============================================================================
# PM2 Application Configuration Script
# For Custom Base AMI with PM2 already installed and systemd configured
# Only saves the application to PM2 process list
# =============================================================================

set -euo pipefail

# Configuration
APP_DIRECTORY="${APP_DIRECTORY:-/var/www/backend}"
APP_USER="${APP_USER:-ubuntu}"
NVM_DIR="${NVM_DIR:-/home/ubuntu/.nvm}"

echo "============================================"
echo "Configuring PM2 Application..."
echo "============================================"

# Check if ecosystem.config.js exists
echo "[1/3] Checking ecosystem config..."
if [ ! -f "${APP_DIRECTORY}/ecosystem.config.js" ]; then
    echo "Creating default ecosystem.config.js..."
    cat > "${APP_DIRECTORY}/ecosystem.config.js" << 'EOF'
module.exports = {
  apps: [
    {
      name: 'backend',
      script: 'server.js',
      cwd: '/var/www/backend',
      instances: 'max',
      exec_mode: 'cluster',
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: '/var/log/app/backend-error.log',
      out_file: '/var/log/app/backend-out.log',
      merge_logs: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};
EOF
    chown ${APP_USER}:${APP_USER} "${APP_DIRECTORY}/ecosystem.config.js"
fi

# Register application with PM2 (but don't start)
echo "[2/3] Registering application with PM2..."
sudo -u ${APP_USER} bash -c "
    export NVM_DIR=\"${NVM_DIR}\"
    [ -s \"\${NVM_DIR}/nvm.sh\" ] && . \"\${NVM_DIR}/nvm.sh\"
    
    cd ${APP_DIRECTORY}
    
    # Delete any existing PM2 processes
    pm2 delete all 2>/dev/null || true
    
    # Start the application to register it
    pm2 start ecosystem.config.js
    
    # Save the process list for startup
    pm2 save
    
    # Stop for clean AMI (will start on boot via systemd)
    pm2 delete all
"

# Verify PM2 dump file exists
echo "[3/3] Verifying PM2 configuration..."
if [ -f "/home/${APP_USER}/.pm2/dump.pm2" ]; then
    echo "PM2 dump file created successfully"
else
    echo "WARNING: PM2 dump file not found"
fi

echo "============================================"
echo "PM2 Configuration Complete!"
echo "Application will start on boot via systemd"
echo "============================================"
