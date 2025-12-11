# AWS AMI Builder with Packer

Production-ready Packer configuration for building AWS AMIs with the backend application baked in.

> [!NOTE]
> **Custom Base AMI**: This configuration uses a custom base AMI that already has **Node.js, PM2 (with systemd), Vault Agent (with systemd), and Nginx** pre-installed.

## 📁 Directory Structure

```
packer/
├── templates/
│   └── backend.pkr.hcl         # Main Packer template
├── variables/
│   ├── variables.pkr.hcl       # Variable definitions
│   └── prod.pkrvars.hcl.example
├── scripts/
│   ├── deploy-app.sh           # Copy app & npm install
│   ├── configure-pm2.sh        # Register app with PM2
│   ├── verify.sh               # Verify build
│   └── cleanup.sh              # Pre-AMI cleanup
├── Makefile
└── README.md
```

## 🚀 Prerequisites

### 1. Custom Base AMI

Your base AMI must have pre-installed:
- ✅ Node.js (via nvm) - version 22.17.0
- ✅ PM2 with systemd service enabled
- ✅ Vault Agent with systemd service
- ✅ PM2 service configured to start after vault-agent
- ✅ Nginx with reverse proxy configured

### 2. AWS Credentials

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="ap-south-1"
```

### 3. Install Packer

```bash
# Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

## ⚙️ Configuration

### 1. Create Variables File

```bash
cd packer
cp variables/prod.pkrvars.hcl.example variables/prod.pkrvars.hcl
```

### 2. Set Your Base AMI ID

Edit `variables/prod.pkrvars.hcl`:

```hcl
# REQUIRED: Your custom base AMI ID
source_ami = "ami-xxxxxxxxxxxxxxxxx"
```

## 🔨 Usage

### Quick Start

```bash
cd packer
make init
make validate
make build
```

### Available Commands

| Command | Description |
|---------|-------------|
| `make init` | Initialize Packer plugins |
| `make validate` | Validate template |
| `make build` | Build the AMI |
| `make build-test` | Test provisioners (skip AMI creation) |
| `make clean` | Remove build artifacts |

## 📋 What Gets Baked

Since the base AMI has everything pre-installed, this Packer build only:

1. **Verifies prerequisites** - Checks Node.js, PM2, Vault, Nginx
2. **Deploys application** - Copies backend code to `/var/www/backend`
3. **Installs dependencies** - Runs `npm ci --only=production`
4. **Configures PM2** - Registers app in PM2 process list
5. **Cleanup** - Removes temp files and caches

## 🔄 Build Flow

```
┌─────────────────────────────┐
│     Custom Base AMI         │
│  (Node, PM2, Vault, Nginx)  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   Verify Prerequisites      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   Copy Backend Code         │
│   npm ci --only=production  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   Register App with PM2     │
│   pm2 save                  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   Cleanup & Create AMI      │
└─────────────────────────────┘
```

## 🔗 Service Dependencies

On boot, services start in this order:

```
vault-agent.service
       │
       ▼ (After=vault-agent.service)
pm2-ubuntu.service
       │
       ▼ (managed by PM2)
backend (Node.js app)
       │
       ▼ (reverse proxy)
nginx.service
```

## 📝 AMI Output

After successful build:
- **AMI ID** in `packer-manifest.json`
- Update your Launch Template with the new AMI ID
- Trigger ASG instance refresh

## 🐛 Troubleshooting

```bash
# Test without creating AMI
make build-test

# Debug mode
PACKER_LOG=1 packer build ...
```
