provider "azuread" {
  tenant_id = var.tenant_id
}

# Client-credentials (M2M) flow.
#
# enable_client_credentials = true makes the module self-assign the listed
# app roles to its own service principal, so tokens issued via
# grant_type=client_credentials carry the roles claim. Without this, M2M
# tokens contain appid but no roles — breaking role-based authz downstream.

module "oidc_provider" {
  source = "../../"

  display_name    = "m2m-demo-app"
  identifier_uris = ["api://m2m-demo-app"]
  redirect_uris   = [] # not used by CC, but variable is required

  # Multi-role app: every value in app_roles becomes an app role on the
  # application, and (because CC is enabled) is self-assigned to the SP
  # so M2M tokens carry all of them in the `roles` claim.
  app_roles = ["service.read", "service.write"]

  enable_client_credentials = true
  # service_principal_roles omitted → defaults to the full app_roles list.
  # Pass an explicit subset here if you want the SP to carry fewer roles
  # than the application declares.
}

output "client_id" {
  value = module.oidc_provider.client_id
}

output "client_secret" {
  value     = module.oidc_provider.client_secret
  sensitive = true
}

output "issuer" {
  value = module.oidc_provider.issuer
}

output "token_endpoint" {
  value = module.oidc_provider.token_endpoint
}

# Drop-in curl that mints a client-credentials token. Run after apply:
#   terraform output -raw mint_token_curl | bash
output "mint_token_curl" {
  sensitive   = true
  description = "Curl command to mint a client-credentials token"
  value       = <<-EOT
    curl -sS -X POST "${module.oidc_provider.token_endpoint}" \
      -d "grant_type=client_credentials" \
      -d "client_id=${module.oidc_provider.client_id}" \
      -d "client_secret=${module.oidc_provider.client_secret}" \
      -d "scope=${module.oidc_provider.client_id}/.default"
  EOT
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
}
