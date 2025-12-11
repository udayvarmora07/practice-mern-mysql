# =============================================================================
# Packer Test Variables
# For Custom Base AMI with Node.js, PM2, Vault Agent, Nginx pre-installed
# =============================================================================

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "source_ami" {
  type        = string
  description = "Custom base AMI ID with Node.js, PM2, Vault, Nginx pre-installed"
  # No default - must be provided
}

variable "instance_type" {
  type        = string
  description = "Instance type for builder"
  default     = "t3.micro"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "nvm_dir" {
  type        = string
  description = "NVM installation directory on base AMI"
  default     = "/home/ubuntu/.nvm"
}

variable "app_directory" {
  type        = string
  description = "Application deployment directory"
  default     = "/var/www/backend"
}

variable "skip_create_ami" {
  type        = bool
  description = "Skip AMI creation for testing provisioners"
  default     = true
}
