.PHONY: help init plan apply destroy fmt validate docs

ENV ?= dev

help:
	@echo "Usage: make <target> [ENV=dev|staging|prod]"
	@echo ""
	@echo "Targets:"
	@echo "  init      terraform init for the target environment"
	@echo "  plan      terraform plan (dry run)"
	@echo "  apply     terraform apply"
	@echo "  destroy   terraform destroy (prompt before execution)"
	@echo "  fmt       format all .tf files"
	@echo "  validate  validate all modules"
	@echo "  docs      generate module documentation (requires terraform-docs)"

init:
	terraform -chdir=environments/$(ENV) init

plan:
	terraform -chdir=environments/$(ENV) plan -var-file=terraform.tfvars

apply:
	terraform -chdir=environments/$(ENV) apply -var-file=terraform.tfvars

destroy:
	terraform -chdir=environments/$(ENV) destroy -var-file=terraform.tfvars

fmt:
	terraform fmt -recursive

validate:
	@for mod in modules/*/; do \
	  echo "Validating $$mod ..."; \
	  terraform -chdir=$$mod init -backend=false -input=false > /dev/null; \
	  terraform -chdir=$$mod validate; \
	done

docs:
	@for mod in modules/*/; do \
	  terraform-docs markdown table $$mod > $$mod/README.md; \
	done
