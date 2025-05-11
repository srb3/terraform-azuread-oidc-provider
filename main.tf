resource "random_uuid" "app_role" {}

resource "azuread_user" "users" {
  for_each              = { for user in var.users : user.username => user }
  user_principal_name   = each.value.username
  display_name          = each.value.display_name
  password              = each.value.password
  force_password_change = false
  mail                  = coalesce(each.value.email, each.value.username)
  mail_nickname         = split("@", coalesce(each.value.email, each.value.username))[0]
}

resource "random_uuid" "app_roles" {
  for_each = toset(local.all_roles)
}

resource "azuread_application" "oidc" {
  display_name    = var.display_name
  identifier_uris = var.identifier_uris
  owners          = [data.azuread_client_config.current.object_id]
  
  dynamic "app_role" {
    for_each = random_uuid.app_roles
    content {
      allowed_member_types = ["User", "Application"]
      description          = app_role.key
      display_name         = app_role.key
      enabled              = true
      id                   = app_role.value.result
      value                = app_role.key
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
  
  # Basic permissions for OIDC
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    
    # Add SCIM permissions only if enabled
    dynamic "resource_access" {
      for_each = var.enable_scim ? [1] : []
      content {
        id   = "741f803b-c850-494e-b5df-cde7c675a1ca" # User.ReadWrite.All
        type = "Role"
      }
    }
    
    dynamic "resource_access" {
      for_each = var.enable_scim ? [1] : []
      content {
        id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.ReadWrite.All
        type = "Role"
      }
    }
    
    dynamic "resource_access" {
      for_each = var.enable_scim ? [1] : []
      content {
        id   = "9116d0a1-7a5e-4fac-8f42-5b4e3f51c11e" # User.Export.All
        type = "Role"
      }
    }
  }
}

resource "azuread_service_principal" "oidc" {
  client_id = azuread_application.oidc.client_id
  
  feature_tags {
    enterprise = true
    gallery    = true
  }
  
  # Add notification email only if SCIM is enabled
  notification_email_addresses = var.enable_scim && var.scim_notification_email != "" ? [var.scim_notification_email] : []
}

# Grant admin consent for Graph permissions only if SCIM is enabled
resource "azuread_service_principal_delegated_permission_grant" "graph" {
  count = var.enable_scim ? 1 : 0
  
  service_principal_object_id          = azuread_service_principal.oidc.object_id
  resource_service_principal_object_id = data.azuread_service_principal.graph.object_id
  claim_values                         = ["User.Read"]
}

# App role assignments for users
resource "azuread_app_role_assignment" "users" {
  for_each            = { for user in var.users : user.username => user }
  app_role_id         = random_uuid.app_roles[each.value.role].result
  principal_object_id = azuread_user.users[each.key].object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

resource "azuread_app_role_assignment" "current_user" {
  app_role_id         = random_uuid.app_roles[var.app_role].result
  principal_object_id = data.azuread_client_config.current.object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

resource "azuread_application_password" "oidc" {
  application_id = azuread_application.oidc.id
}

data "azuread_client_config" "current" {}

data "azuread_service_principal" "graph" {
  client_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
}

locals {
  all_roles  = distinct(concat([var.app_role], [for user in var.users : user.role]))
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
