# =============================================================================
# Packer Variables Definition
# For Custom Base AMI with Node.js, PM2, Vault Agent, Nginx pre-installed
# =============================================================================

# -----------------------------------------------------------------------------
# AWS Configuration
# -----------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "AWS region where the AMI will be built and stored"
  default     = "ap-south-1"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key (use env var or pkrvars file)"
  default     = ""
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key (use env var or pkrvars file)"
  default     = ""
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Source AMI Configuration
# IMPORTANT: Specify your custom base AMI ID here
# -----------------------------------------------------------------------------

variable "source_ami" {
  type        = string
  description = "Custom base AMI ID with Node.js, PM2, Vault Agent, Nginx pre-installed"
  # No default - must be provided
}

# -----------------------------------------------------------------------------
# Instance Configuration
# -----------------------------------------------------------------------------

variable "instance_type" {
  type        = string
  description = "EC2 instance type for building the AMI"
  default     = "t3.micro"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for connecting to the builder instance"
  default     = "ubuntu"
}

variable "ssh_timeout" {
  type        = string
  description = "SSH connection timeout"
  default     = "10m"
}

# -----------------------------------------------------------------------------
# VPC/Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "VPC ID for building the AMI. Leave empty for default VPC"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for building the AMI. Leave empty for default subnet"
  default     = ""
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with the builder instance"
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs to attach to the builder instance"
  default     = []
}

# -----------------------------------------------------------------------------
# Application Configuration
# -----------------------------------------------------------------------------

variable "app_name" {
  type        = string
  description = "Application name for tagging and naming"
  default     = "backend"
}

variable "app_version" {
  type        = string
  description = "Application version for tagging"
  default     = "latest"
}

variable "app_env" {
  type        = string
  description = "Application environment (dev, staging, prod)"
  default     = "prod"
}

variable "app_directory" {
  type        = string
  description = "Directory where the application will be deployed"
  default     = "/var/www/backend"
}

variable "app_user" {
  type        = string
  description = "System user to run the application"
  default     = "ubuntu"
}

# -----------------------------------------------------------------------------
# Pre-installed Software Paths (from base AMI)
# Adjust these if your base AMI uses different paths
# -----------------------------------------------------------------------------

variable "nvm_dir" {
  type        = string
  description = "NVM installation directory on base AMI"
  default     = "/home/ubuntu/.nvm"
}

variable "node_version" {
  type        = string
  description = "Node.js version installed on base AMI"
  default     = "22.17.0"
}

# -----------------------------------------------------------------------------
# AMI Configuration
# -----------------------------------------------------------------------------

variable "ami_description" {
  type        = string
  description = "Description for the created AMI"
  default     = "Backend Application AMI (based on custom AMI with Node.js, PM2, Vault, Nginx)"
}

variable "ami_regions" {
  type        = list(string)
  description = "Additional regions to copy the AMI to"
  default     = []
}

variable "encrypt_boot" {
  type        = bool
  description = "Encrypt the root volume of the AMI"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for encrypting the AMI"
  default     = ""
}

# -----------------------------------------------------------------------------
# EBS Volume Configuration
# -----------------------------------------------------------------------------

variable "volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 20
}

variable "volume_type" {
  type        = string
  description = "EBS volume type"
  default     = "gp3"
}

variable "delete_on_termination" {
  type        = bool
  description = "Delete root volume on instance termination"
  default     = true
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the AMI"
  default     = {}
}

variable "team" {
  type        = string
  description = "Team name for tagging"
  default     = "devops"
}

# -----------------------------------------------------------------------------
# Build Configuration
# -----------------------------------------------------------------------------

variable "skip_create_ami" {
  type        = bool
  description = "Skip creating the AMI (for testing provisioners)"
  default     = false
}

variable "force_deregister" {
  type        = bool
  description = "Force deregister an existing AMI with the same name"
  default     = false
}

variable "force_delete_snapshot" {
  type        = bool
  description = "Force delete snapshots when deregistering"
  default     = false
}
