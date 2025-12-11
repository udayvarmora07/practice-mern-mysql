# =============================================================================
# Packer Testing Makefile
# =============================================================================

.PHONY: help init validate test build clean

.DEFAULT_GOAL := help

TEMPLATE := templates/test.pkr.hcl
VARS_FILE := variables/variables.pkr.hcl
PKR_VARS_FILE := variables/test.pkrvars.hcl

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

help: ## Show available commands
	@echo "$(BLUE)Packer Testing$(NC)"
	@echo "==============="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-12s$(NC) %s\n", $$1, $$2}'
	@echo ""

init: ## Initialize Packer plugins
	@echo "$(BLUE)Initializing...$(NC)"
	packer init $(TEMPLATE)
	@echo "$(GREEN)Done!$(NC)"

validate: init ## Validate template
	@echo "$(BLUE)Validating...$(NC)"
	packer validate -var-file=$(VARS_FILE) $(TEMPLATE)
	@echo "$(GREEN)Valid!$(NC)"

test: validate ## Run test build (no AMI creation)
	@echo "$(BLUE)Running test build (skip AMI)...$(NC)"
	chmod +x scripts/*.sh
	packer build -var-file=$(VARS_FILE) -var 'skip_create_ami=true' $(TEMPLATE)

build: validate ## Build actual AMI
	@echo "$(BLUE)Building AMI...$(NC)"
	chmod +x scripts/*.sh
	packer build -var-file=$(VARS_FILE) -var 'skip_create_ami=false' $(TEMPLATE)

debug: init ## Test with debug output
	@echo "$(BLUE)Debug build...$(NC)"
	chmod +x scripts/*.sh
	PACKER_LOG=1 packer build -var-file=$(VARS_FILE) -var 'skip_create_ami=true' $(TEMPLATE)

fmt: ## Format HCL files
	packer fmt -recursive .

setup: ## Create test.pkrvars.hcl from example
	@if [ -f "variables/test.pkrvars.hcl" ]; then \
		echo "$(YELLOW)test.pkrvars.hcl already exists!$(NC)"; \
	else \
		cp variables/test.pkrvars.hcl.example variables/test.pkrvars.hcl; \
		echo "$(GREEN)Created test.pkrvars.hcl$(NC)"; \
	fi

clean: ## Clean up artifacts
	rm -f packer-manifest.json *.log
	@echo "$(GREEN)Cleaned!$(NC)"
