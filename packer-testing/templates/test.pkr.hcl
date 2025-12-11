# =============================================================================
# Packer Test Template
# For Custom Base AMI with Node.js, PM2, Vault Agent, Nginx pre-installed
# =============================================================================

packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

# =============================================================================
# Locals
# =============================================================================

locals {
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
  ami_name  = "backend-test-${local.timestamp}"
}

# =============================================================================
# Source
# =============================================================================

source "amazon-ebs" "test" {
  region        = var.aws_region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  ssh_timeout   = "10m"

  ami_name        = local.ami_name
  skip_create_ami = var.skip_create_ami

  temporary_security_group_source_cidrs = ["0.0.0.0/0"]
  associate_public_ip_address           = true

  tags = {
    Name        = "backend-test-ami"
    Environment = "test"
    Builder     = "packer"
  }

  run_tags = {
    Name = "packer-test-builder"
  }
}

# =============================================================================
# Build
# =============================================================================

build {
  name    = "test-build"
  sources = ["source.amazon-ebs.test"]

  # Stage 1: Verify base AMI
  provisioner "shell" {
    inline = [
      "echo '=== Verifying Base AMI ==='",
      "export NVM_DIR=\"${var.nvm_dir}\"",
      "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"",
      "echo \"Node.js: $(node --version)\"",
      "echo \"npm: $(npm --version)\"",
      "echo \"PM2: $(pm2 --version)\"",
      "systemctl is-enabled vault-agent.service && echo 'Vault Agent: enabled' || echo 'Vault Agent: not found'",
      "nginx -v 2>&1 || echo 'Nginx: not found'",
      "echo '=== Base AMI OK ==='",
    ]
  }

  # Stage 2: Prepare directory
  provisioner "shell" {
    inline = [
      "sudo mkdir -p ${var.app_directory}",
      "sudo rm -rf ${var.app_directory}/*",
      "sudo chown -R ${var.ssh_username}:${var.ssh_username} ${var.app_directory}"
    ]
  }

  # Stage 3: Copy application
  provisioner "file" {
    source      = "${path.root}/../../backend/"
    destination = "/tmp/backend"
  }

  # Stage 4: Deploy application
  provisioner "shell" {
    environment_vars = [
      "APP_DIRECTORY=${var.app_directory}",
      "APP_USER=${var.ssh_username}",
      "NVM_DIR=${var.nvm_dir}"
    ]
    script          = "${path.root}/../scripts/deploy-app.sh"
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  # Stage 5: Verify
  provisioner "shell" {
    script = "${path.root}/../scripts/verify.sh"
  }

  post-processor "shell-local" {
    inline = [
      "echo ''",
      "echo '============================================'",
      "echo 'Test Build Complete!'",
      "echo 'skip_create_ami = ${var.skip_create_ami}'",
      "echo '============================================'",
    ]
  }
}
