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

  lifecycle {
    precondition {
      condition     = length(local.app_roles_effective) > 0
      error_message = "At least one app role must be declared — set either `app_role` (string) or `app_roles` (list(string))."
    }
  }

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

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "oidc" {
  client_id = azuread_application.oidc.client_id

  feature_tags {
    enterprise = true
    gallery    = true
  }
}

resource "azuread_app_role_assignment" "users" {
  for_each            = { for user in var.users : user.username => user }
  app_role_id         = random_uuid.app_roles[each.value.role].result
  principal_object_id = azuread_user.users[each.key].object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

resource "azuread_app_role_assignment" "current_user" {
  # Assign the first effective app role to the tenant user running
  # `terraform apply`. Kept as a single assignment (not one-per-role)
  # to preserve v2.1 behaviour for callers using the single-value
  # `app_role` input.
  app_role_id         = random_uuid.app_roles[local.app_roles_effective[0]].result
  principal_object_id = data.azuread_client_config.current.object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

# Self-assign app roles to this app's own service principal so that
# client-credentials (M2M) tokens issued for it carry the roles claim.
# Without this, M2M tokens contain appid but no roles → role-based
# authorization (e.g. Kong post-function checking method:path against
# roles[]) won't work.
resource "azuread_app_role_assignment" "service_principal" {
  for_each            = toset(local.sp_roles)
  app_role_id         = random_uuid.app_roles[each.value].result
  principal_object_id = azuread_service_principal.oidc.object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

resource "azuread_application_password" "oidc" {
  application_id = azuread_application.oidc.id
}

data "azuread_client_config" "current" {}

locals {
  # Union of the legacy single-value `app_role` (if set) and the
  # new list-valued `app_roles`. De-duplicated so callers that set
  # both can't accidentally create a duplicate role.
  app_roles_effective = distinct(concat(
    var.app_role != null ? [var.app_role] : [],
    var.app_roles,
  ))
  sp_roles = var.enable_client_credentials ? (
    length(var.service_principal_roles) > 0 ? var.service_principal_roles : local.app_roles_effective
  ) : []
  all_roles = distinct(concat(
    local.app_roles_effective,
    [for user in var.users : user.role],
    local.sp_roles,
  ))
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

