.PHONY: test clean validate

test_basic:
ifndef TENANT_ID
	$(error TENANT_ID is not set. Usage: make test_basic TENANT_ID=your-tenant-id)
endif
	cd examples/basic && \
	terraform init && \
	terraform plan -var="tenant_id=$(TENANT_ID)" && \
	terraform apply -var="tenant_id=$(TENANT_ID)" -auto-approve

test_additional_users:
ifndef TENANT_ID
	$(error TENANT_ID is not set. Usage: make test_additional_users TENANT_ID=your-tenant-id)
endif
ifndef USER_PASSWORD
	$(error USER_PASSWORD is not set. Usage: make test_additional_users USER_PASSWORD=some-password)
endif
ifndef DOMAIN
	$(error DOMAIN is not set. Usage: make test_additional_users DOMAIN=some-domain-name)
endif
	cd examples/additional_users && \
	terraform init && \
	terraform plan -var="tenant_id=$(TENANT_ID)" -var="password=$(USER_PASSWORD)" \
	  -var="domain=$(DOMAIN)" && \
	terraform apply -var="tenant_id=$(TENANT_ID)" -var="password=$(USER_PASSWORD)" \
	  -var="domain=$(DOMAIN)" -auto-approve

test_client_credentials:
ifndef TENANT_ID
	$(error TENANT_ID is not set. Usage: make test_client_credentials TENANT_ID=your-tenant-id)
endif
	cd examples/client_credentials && \
	terraform init && \
	terraform plan -var="tenant_id=$(TENANT_ID)" && \
	terraform apply -var="tenant_id=$(TENANT_ID)" -auto-approve

clean_client_credentials:
ifndef TENANT_ID
	$(error TENANT_ID is not set. Usage: make clean_client_credentials TENANT_ID=your-tenant-id)
endif
	cd examples/client_credentials && terraform destroy -var="tenant_id=$(TENANT_ID)" -auto-approve
	rm -rf examples/client_credentials/.terraform examples/client_credentials/.terraform.lock.hcl

validate_client_credentials:
	cd examples/client_credentials && terraform init && terraform validate

validate: validate_basic validate_additional_users validate_client_credentials
test: test_basic clean_basic test_additional_users clean_additional_users test_client_credentials clean_client_credentials

clean_basic:
ifndef TENANT_ID
	$(error TENANT_ID is not set. Usage: make test_basic TENANT_ID=your-tenant-id)
endif
	cd examples/basic && terraform destroy -var="tenant_id=$(TENANT_ID)" -auto-approve
	rm -rf examples/basic/.terraform examples/basic/.terraform.lock.hcl

clean_additional_users:
ifndef TENANT_ID
	$(error TENANT_ID is not set. Usage: make test_additional_users TENANT_ID=your-tenant-id)
endif
ifndef USER_PASSWORD
	$(error USER_PASSWORD is not set. Usage: make test_additional_users USER_PASSWORD=some-password)
endif
ifndef DOMAIN
	$(error DOMAIN is not set. Usage: make test_additional_users DOMAIN=some-domain-name)
endif
	cd examples/additional_users && terraform destroy -var="tenant_id=$(TENANT_ID)" \
		-var="password=$(USER_PASSWORD)" -var="domain=$(DOMAIN)" -auto-approve
	rm -rf examples/additional_users/.terraform examples/additional_users/.terraform.lock.hcl

validate_basic:
	cd examples/basic && terraform init && terraform validate

validate_additional_users:
	cd examples/additional_users && terraform init && terraform validate
