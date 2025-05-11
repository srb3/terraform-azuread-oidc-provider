output "application" {
  value = azuread_application.oidc
}

output "client_id" {
  value = azuread_application.oidc.client_id
}

output "client_secret" {
  value = azuread_application_password.oidc.value
}

output "base-url" {
  value = local.base
}

output "metadata-url" {
  value = local.meta
}

output "token_endpoint" {
  value = jsondecode(data.http.metadata.response_body).token_endpoint
}

output "jwks_uri" {
  value = jsondecode(data.http.metadata.response_body).jwks_uri
}

output "issuer" {
  value = jsondecode(data.http.metadata.response_body).issuer
}

output "userinfo_endpoint" {
  value = jsondecode(data.http.metadata.response_body).userinfo_endpoint
}

output "authorization_endpoint" {
  value = jsondecode(data.http.metadata.response_body).authorization_endpoint
}

output "device_authorization_endpoint" {
  value = jsondecode(data.http.metadata.response_body).device_authorization_endpoint
}

output "end_session_endpoint" {
  value = jsondecode(data.http.metadata.response_body).end_session_endpoint
}

output "kerberos_endpoint" {
  value = jsondecode(data.http.metadata.response_body).kerberos_endpoint
}

output "metadata-url-alt" {
  value = local.meta_alt
}

output "token_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).token_endpoint
}

output "jwks_uri_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).jwks_uri
}

output "issuer_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).issuer
}

output "userinfo_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).userinfo_endpoint
}

output "authorization_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).authorization_endpoint
}

output "device_authorization_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).device_authorization_endpoint
}

output "end_session_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).end_session_endpoint
}

output "kerberos_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.response_body).kerberos_endpoint
}
