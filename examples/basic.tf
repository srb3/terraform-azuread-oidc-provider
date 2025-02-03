provider "azuread" {
  tenant_id = var.tenant_id
}

module "oidc_provider" {
  source = "../"  # Path to module root
  
  display_name = "my-oidc-app"
  identifier_uris = [
    "https://my-app.example.com"
  ]
  redirect_uris = [
    "https://my-app.example.com/oauth/callback",
    "http://localhost:3000/callback"
  ]
}

# Example outputs
output "client_id" {
  value = module.oidc_provider.client_id
}

output "client_secret" {
  value     = module.oidc_provider.client_secret
  sensitive = true
}

output "metadata_url" {
  value = module.oidc_provider.metadata-url
}

# Variables
variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
}
