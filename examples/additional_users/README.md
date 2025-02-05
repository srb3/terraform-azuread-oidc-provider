# Basic OIDC Provider Example

This example demonstrates basic usage of the Azure AD OIDC Provider module.

## Usage

1. Copy the example to your local environment
2. Update `terraform.tfvars` with your Azure AD tenant ID
3. Run:
```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Azure AD tenant with permissions to create applications
- Terraform >= 1.0.0
- Azure AD Provider >= 4.17.0
