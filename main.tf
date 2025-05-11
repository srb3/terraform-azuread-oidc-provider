# Random UUID for app role
resource "random_uuid" "app_role" {}

# Create users
resource "azuread_user" "users" {
  for_each              = { for user in var.users : user.username => user }
  user_principal_name   = each.value.username
  display_name          = each.value.display_name
  password              = each.value.password
  force_password_change = false
  mail                  = coalesce(each.value.email, each.value.username)
  mail_nickname         = split("@", coalesce(each.value.email, each.value.username))[0]
}

# Random UUIDs for app roles
resource "random_uuid" "app_roles" {
  for_each = toset(local.all_roles)
}

# Data sources
data "azuread_client_config" "current" {}

locals {
  all_roles = distinct(concat([var.app_role], [for user in var.users : user.role]))
  
  # Define the special msiam_access role for SCIM (required for SCIM)
  msiam_access_role = var.enable_scim ? {
    "msiam_access" = {
      id = "b9632174-c057-4f7e-951b-be3adc52bfe6"  # Fixed UUID required for SCIM
      description = "msiam_access"
      value = null  # Must be null for msiam_access
    }
  } : {}
  
  # User app role for SCIM
  user_app_role = var.enable_scim ? {
    "User" = {
      id = "18d14569-c3bd-439b-9a66-3a2aee01d14f"  # Fixed UUID
      description = "User"
      value = null
    }
  } : {}
  
  # Get all app roles including SCIM roles
  normal_app_roles = { for role in toset(local.all_roles) : role => {
    id = random_uuid.app_roles[role].result
    description = role
    value = role
  }}
  
  # Combine all app roles
  all_app_roles = var.enable_scim ? merge(
    local.normal_app_roles,
    local.msiam_access_role,
    local.user_app_role
  ) : local.normal_app_roles
}

# Azure AD Application
resource "azuread_application" "oidc" {
  display_name    = var.display_name
  identifier_uris = var.identifier_uris
  owners          = [data.azuread_client_config.current.object_id]
  
  sign_in_audience = "AzureADMyOrg"
  
  # Application roles including SCIM roles
  dynamic "app_role" {
    for_each = local.all_app_roles
    content {
      allowed_member_types = ["User"]
      description          = app_role.value.description
      display_name         = app_role.key
      enabled              = true
      id                   = app_role.value.id
      value                = app_role.value.value
    }
  }
  
  web {
    redirect_uris = var.redirect_uris
    
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  
  api {
    requested_access_token_version = 2
  }
  
  optional_claims {
    id_token {
      name = "groups"
    }
  }
  
  group_membership_claims = ["All"]
  
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
}

# Service Principal - to enable SCIM
resource "azuread_service_principal" "oidc" {
  client_id = azuread_application.oidc.client_id
  
  app_role_assignment_required = true  # Required for SCIM
  
  # Add notification email for SCIM provisioning
  notification_email_addresses = var.enable_scim && var.scim_notification_email != "" ? [var.scim_notification_email] : []
  
  # These tags are crucial for enabling SCIM provisioning
  tags = var.enable_scim ? [
    "WindowsAzureActiveDirectoryCustomSingleSignOnApplication",
    "WindowsAzureActiveDirectoryIntegratedApp"
  ] : ["WindowsAzureActiveDirectoryIntegratedApp"]
}

# App role assignments for users
resource "azuread_app_role_assignment" "users" {
  for_each            = { for user in var.users : user.username => user }
  app_role_id         = local.all_app_roles[each.value.role].id
  principal_object_id = azuread_user.users[each.key].object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

# App role assignment for current user
resource "azuread_app_role_assignment" "current_user" {
  app_role_id         = local.all_app_roles[var.app_role].id
  principal_object_id = data.azuread_client_config.current.object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

resource "azuread_application_password" "oidc" {
  application_id = azuread_application.oidc.id
}

locals {
  base       = "https://login.microsoftonline.com"
  base_alt   = "https://sts.windows.net"
  tenant     = "${local.base}/${data.azuread_client_config.current.tenant_id}"
  tenant_alt = "${local.base_alt}/${data.azuread_client_config.current.tenant_id}"
  issuer     = "${local.tenant}/v2.0"
  issuer_alt = "${local.tenant_alt}/v2.0"
  meta       = "${local.issuer}/.well-known/openid-configuration"
  meta_alt   = "${local.issuer_alt}/.well-known/openid-configuration"
}

data "http" "metadata" {
  url = local.meta
  request_headers = {
    Accept = "application/json"
  }
}

data "http" "metadata_alt" {
  url = local.meta_alt
  request_headers = {
    Accept = "application/json"
  }
}
