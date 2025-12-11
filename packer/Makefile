# =============================================================================
# Packer Makefile
# Build Automation for AWS AMI Creation
# =============================================================================

.PHONY: help init validate fmt build clean inspect

# Default target
.DEFAULT_GOAL := help

# Variables
TEMPLATE_DIR := templates
VARIABLES_DIR := variables
TEMPLATE := $(TEMPLATE_DIR)/backend.pkr.hcl
VARS_FILE := $(VARIABLES_DIR)/variables.pkr.hcl
PKR_VARS_FILE ?= $(VARIABLES_DIR)/prod.pkrvars.hcl

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Help target
help: ## Show this help message
	@echo "$(BLUE)Packer Build Automation$(NC)"
	@echo "========================"
	@echo ""
	@echo "Usage: make [target] [PKR_VARS_FILE=path/to/vars.pkrvars.hcl]"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make build                           # Build with default vars file"
	@echo "  make build PKR_VARS_FILE=staging.pkrvars.hcl"
	@echo "  make validate                        # Validate template"
	@echo ""

# Initialize Packer plugins
init: ## Initialize Packer and download plugins
	@echo "$(BLUE)Initializing Packer...$(NC)"
	packer init $(TEMPLATE)
	@echo "$(GREEN)Initialization complete!$(NC)"

# Validate template
validate: init ## Validate the Packer template
	@echo "$(BLUE)Validating template...$(NC)"
	@if [ -f "$(PKR_VARS_FILE)" ]; then \
		packer validate -var-file=$(VARS_FILE) -var-file=$(PKR_VARS_FILE) $(TEMPLATE); \
	else \
		echo "$(YELLOW)Warning: $(PKR_VARS_FILE) not found, using defaults$(NC)"; \
		packer validate -var-file=$(VARS_FILE) $(TEMPLATE); \
	fi
	@echo "$(GREEN)Validation successful!$(NC)"

# Format HCL files
fmt: ## Format all Packer HCL files
	@echo "$(BLUE)Formatting Packer files...$(NC)"
	packer fmt -recursive .
	@echo "$(GREEN)Formatting complete!$(NC)"

# Check formatting
fmt-check: ## Check if HCL files are properly formatted
	@echo "$(BLUE)Checking format...$(NC)"
	packer fmt -check -recursive .
	@echo "$(GREEN)Format check passed!$(NC)"

# Build AMI
build: validate ## Build the AMI (validates first)
	@echo "$(BLUE)Building AMI...$(NC)"
	@if [ -f "$(PKR_VARS_FILE)" ]; then \
		packer build -var-file=$(VARS_FILE) -var-file=$(PKR_VARS_FILE) $(TEMPLATE); \
	else \
		echo "$(RED)Error: $(PKR_VARS_FILE) not found!$(NC)"; \
		echo "Create it from prod.pkrvars.hcl.example or specify a different file:"; \
		echo "  make build PKR_VARS_FILE=your-vars.pkrvars.hcl"; \
		exit 1; \
	fi
	@echo "$(GREEN)Build complete!$(NC)"

# Build with debug output
build-debug: validate ## Build with debug output
	@echo "$(BLUE)Building AMI with debug output...$(NC)"
	PACKER_LOG=1 packer build -var-file=$(VARS_FILE) -var-file=$(PKR_VARS_FILE) $(TEMPLATE)

# Test build (skip AMI creation)
build-test: init ## Test provisioners without creating AMI
	@echo "$(BLUE)Testing build (skip AMI creation)...$(NC)"
	@if [ -f "$(PKR_VARS_FILE)" ]; then \
		packer build -var 'skip_create_ami=true' -var-file=$(VARS_FILE) -var-file=$(PKR_VARS_FILE) $(TEMPLATE); \
	else \
		echo "$(YELLOW)Warning: $(PKR_VARS_FILE) not found, using defaults$(NC)"; \
		packer build -var 'skip_create_ami=true' -var-file=$(VARS_FILE) $(TEMPLATE); \
	fi

# Inspect template
inspect: init ## Inspect the template configuration
	@echo "$(BLUE)Inspecting template...$(NC)"
	packer inspect $(TEMPLATE)

# Clean build artifacts
clean: ## Remove build artifacts and cache
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -f packer-manifest.json
	rm -rf packer_cache/
	rm -f *.log
	@echo "$(GREEN)Cleanup complete!$(NC)"

# Show environment info
info: ## Show environment and configuration info
	@echo "$(BLUE)Environment Information$(NC)"
	@echo "========================"
	@echo "Packer version: $$(packer version)"
	@echo "Template: $(TEMPLATE)"
	@echo "Variables file: $(VARS_FILE)"
	@echo "PKR vars file: $(PKR_VARS_FILE)"
	@echo ""
	@echo "$(BLUE)AWS Configuration$(NC)"
	@echo "AWS_PROFILE: $${AWS_PROFILE:-not set}"
	@echo "AWS_REGION: $${AWS_REGION:-not set}"
	@echo ""

# Create vars file from example
setup: ## Create prod.pkrvars.hcl from example
	@if [ -f "$(VARIABLES_DIR)/prod.pkrvars.hcl" ]; then \
		echo "$(YELLOW)prod.pkrvars.hcl already exists!$(NC)"; \
	else \
		cp $(VARIABLES_DIR)/prod.pkrvars.hcl.example $(VARIABLES_DIR)/prod.pkrvars.hcl; \
		echo "$(GREEN)Created prod.pkrvars.hcl - please edit with your values$(NC)"; \
	fi
