.PHONY: test clean validate

ifndef TENANT_ID
$(error TENANT_ID is not set. Usage: make test TENANT_ID=your-tenant-id)
endif

test:
	cd examples && \
	terraform init && \
	terraform plan -var="tenant_id=$(TENANT_ID)" && \
	terraform apply -var="tenant_id=$(TENANT_ID)" -auto-approve

clean:
	cd examples && terraform destroy -var="tenant_id=$(TENANT_ID)" -auto-approve
	rm -rf examples/.terraform examples/.terraform.lock.hcl

validate:
	cd examples && terraform init && terraform validate
