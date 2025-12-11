# Packer Testing

Simplified Packer configuration for testing AMI builds with **custom base AMI**.

> **Note**: Uses custom base AMI with Node.js, PM2, Vault Agent, Nginx pre-installed.

## Structure

```
packer-testing/
├── templates/test.pkr.hcl
├── variables/
│   ├── variables.pkr.hcl
│   └── test.pkrvars.hcl.example
├── scripts/
│   ├── deploy-app.sh
│   └── verify.sh
└── Makefile
```

## Quick Start

```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

# Create variables file
cp variables/test.pkrvars.hcl.example variables/test.pkrvars.hcl
# Edit and set source_ami = "ami-your-custom-ami"

# Test (no AMI created)
make test

# Build actual AMI
make build
```

## Commands

| Command | Description |
|---------|-------------|
| `make test` | Test provisioners (skip AMI) |
| `make build` | Create actual AMI |
| `make debug` | Verbose logging |

## What It Does

1. ✅ Verifies base AMI (Node, PM2, Vault, Nginx)
2. ✅ Copies backend code
3. ✅ Runs `npm ci --only=production`
4. ✅ Verifies installation
