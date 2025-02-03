resource "random_uuid" "app_role" {}
data "azuread_user" "current_user" {
  object_id = data.azuread_client_config.current.object_id
}
resource "azuread_application" "oidc" {
  display_name    = var.display_name
  identifier_uris = var.identifier_uris
  owners          = [data.azuread_client_config.current.object_id]

  app_role {
    allowed_member_types = ["User", "Application"]
    description         = var.app_role
    display_name        = var.app_role
    enabled             = true
    id                  = random_uuid.app_role.result
    value               = var.app_role
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

resource "azuread_app_role_assignment" "current_user" {
  app_role_id         = random_uuid.app_role.result
  principal_object_id = data.azuread_user.current_user.object_id
  resource_object_id  = azuread_service_principal.oidc.object_id
}

resource "azuread_application_password" "oidc" {
  application_id = azuread_application.oidc.id
}

data "azuread_client_config" "current" {}

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

