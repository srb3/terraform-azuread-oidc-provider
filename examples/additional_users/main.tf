provider "azuread" {
  tenant_id = var.tenant_id
}

module "oidc_provider" {
  source = "../../"

  display_name    = "my-oidc-app"
  identifier_uris = ["https://my-app.example.com"]
  redirect_uris   = ["https://my-app.example.com/oauth/callback"]
  app_role        = "kong-admin"
  users = [
    {
      username     = "user1@${var.domain}"
      display_name = "User One"
      role         = "admin"
      password     = var.password 
    },
    {
      username     = "user2@${var.domain}"
      display_name = "User Two"
      role         = "reader"
      password     = var.password
    }
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

variable "domain" {
  type        = string
  description = "Azure AD domain"
}

variable "password" {
  type        = string
  description = "The password for the new Azure AS users"
}
