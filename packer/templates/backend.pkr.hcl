# =============================================================================
# Packer Template for Backend Application AMI
# Uses Custom Base AMI with Node.js, PM2, Vault Agent, Nginx pre-installed
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
# Local Variables
# =============================================================================

locals {
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
  ami_name  = "${var.app_name}-${var.app_env}-${local.timestamp}"

  common_tags = merge(
    {
      Name        = "${var.app_name}-ami"
      Application = var.app_name
      Environment = var.app_env
      Version     = var.app_version
      Team        = var.team
      BuildDate   = local.timestamp
      SourceAMI   = var.source_ami
      Builder     = "packer"
    },
    var.tags
  )

  build_tags = merge(
    local.common_tags,
    {
      Name = "${var.app_name}-packer-builder"
    }
  )
}

# =============================================================================
# Source Configuration
# =============================================================================

source "amazon-ebs" "backend" {
  # AWS Authentication
  access_key = var.aws_access_key != "" ? var.aws_access_key : null
  secret_key = var.aws_secret_key != "" ? var.aws_secret_key : null
  region     = var.aws_region

  # Source AMI - Your custom base AMI
  source_ami = var.source_ami

  # Instance Configuration
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  ssh_timeout   = var.ssh_timeout

  # Network Configuration
  vpc_id                      = var.vpc_id != "" ? var.vpc_id : null
  subnet_id                   = var.subnet_id != "" ? var.subnet_id : null
  associate_public_ip_address = var.associate_public_ip_address
  security_group_ids          = length(var.security_group_ids) > 0 ? var.security_group_ids : null

  temporary_security_group_source_cidrs = ["0.0.0.0/0"]

  # AMI Configuration
  ami_name        = local.ami_name
  ami_description = var.ami_description
  ami_regions     = var.ami_regions

  # Encryption
  encrypt_boot = var.encrypt_boot
  kms_key_id   = var.kms_key_id != "" ? var.kms_key_id : null

  # EBS Configuration
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypt_boot
  }

  # Build Options
  skip_create_ami       = var.skip_create_ami
  force_deregister      = var.force_deregister
  force_delete_snapshot = var.force_delete_snapshot

  # Tags
  tags     = local.common_tags
  run_tags = local.build_tags

  # IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

# =============================================================================
# Build Configuration
# =============================================================================

build {
  name    = "backend-ami"
  sources = ["source.amazon-ebs.backend"]

  # ---------------------------------------------------------------------------
  # Stage 1: Verify Base AMI Prerequisites
  # ---------------------------------------------------------------------------

  provisioner "shell" {
    inline = [
      "echo '============================================'",
      "echo 'Verifying Base AMI Prerequisites...'",
      "echo '============================================'",
      "",
      "# Verify Node.js",
      "export NVM_DIR=\"${var.nvm_dir}\"",
      "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"",
      "echo \"Node.js: $(node --version)\"",
      "echo \"npm: $(npm --version)\"",
      "",
      "# Verify PM2",
      "echo \"PM2: $(pm2 --version)\"",
      "",
      "# Verify Vault Agent service",
      "if systemctl is-enabled vault-agent.service &>/dev/null; then",
      "  echo 'Vault Agent: Service enabled'",
      "else",
      "  echo 'WARNING: vault-agent.service not found or not enabled'",
      "fi",
      "",
      "# Verify Nginx",
      "if command -v nginx &>/dev/null; then",
      "  echo \"Nginx: $(nginx -v 2>&1)\"",
      "else",
      "  echo 'WARNING: Nginx not found'",
      "fi",
      "",
      "echo 'Base AMI verification complete!'",
    ]
  }

  # ---------------------------------------------------------------------------
  # Stage 2: Prepare Application Directory
  # ---------------------------------------------------------------------------

  provisioner "shell" {
    inline = [
      "echo '============================================'",
      "echo 'Preparing Application Directory...'",
      "echo '============================================'",
      "",
      "# Create app directory if not exists",
      "sudo mkdir -p ${var.app_directory}",
      "",
      "# Clean existing application files (if any)",
      "sudo rm -rf ${var.app_directory}/*",
      "",
      "# Set ownership",
      "sudo chown -R ${var.app_user}:${var.app_user} ${var.app_directory}",
      "",
      "echo 'Directory prepared: ${var.app_directory}'",
    ]
  }

  # ---------------------------------------------------------------------------
  # Stage 3: Copy Application Files
  # ---------------------------------------------------------------------------

  provisioner "file" {
    source      = "${path.root}/../../backend/"
    destination = "/tmp/backend"
  }

  # ---------------------------------------------------------------------------
  # Stage 4: Deploy Application
  # ---------------------------------------------------------------------------

  provisioner "shell" {
    environment_vars = [
      "APP_DIRECTORY=${var.app_directory}",
      "APP_USER=${var.app_user}",
      "NVM_DIR=${var.nvm_dir}"
    ]
    script          = "${path.root}/../scripts/deploy-app.sh"
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  # ---------------------------------------------------------------------------
  # Stage 5: Configure PM2 Application
  # ---------------------------------------------------------------------------

  provisioner "shell" {
    environment_vars = [
      "APP_DIRECTORY=${var.app_directory}",
      "APP_USER=${var.app_user}",
      "NVM_DIR=${var.nvm_dir}"
    ]
    script          = "${path.root}/../scripts/configure-pm2.sh"
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  # ---------------------------------------------------------------------------
  # Stage 6: Final Verification
  # ---------------------------------------------------------------------------

  provisioner "shell" {
    script = "${path.root}/../scripts/verify.sh"
  }

  # ---------------------------------------------------------------------------
  # Stage 7: Cleanup
  # ---------------------------------------------------------------------------

  provisioner "shell" {
    script          = "${path.root}/../scripts/cleanup.sh"
    execute_command = "sudo -S sh -c '{{ .Path }}'"
  }

  # ---------------------------------------------------------------------------
  # Post-Processors
  # ---------------------------------------------------------------------------

  post-processor "manifest" {
    output     = "${path.root}/../packer-manifest.json"
    strip_path = true
    custom_data = {
      app_name    = var.app_name
      app_version = var.app_version
      app_env     = var.app_env
      aws_region  = var.aws_region
      source_ami  = var.source_ami
      build_time  = local.timestamp
    }
  }

  post-processor "shell-local" {
    inline = [
      "echo '============================================'",
      "echo 'AMI Build Complete!'",
      "echo 'AMI Name: ${local.ami_name}'",
      "echo 'Region: ${var.aws_region}'",
      "echo 'Based on: ${var.source_ami}'",
      "echo '============================================'"
    ]
  }
}
