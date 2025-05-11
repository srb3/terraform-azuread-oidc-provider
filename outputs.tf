output "application" {
  value = local.application
}

output "client_id" {
  value = local.application.client_id
}

output "client_secret" {
  value     = azuread_application_password.oidc.value
  sensitive = true
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

# SCIM-specific outputs
output "scim_enabled" {
  value = var.enable_scim
}

output "scim_configuration_instructions" {
  value = (var.enable_scim ? <<-EOT
    SCIM is enabled for this application. To complete configuration:
    
    1. Navigate to Azure Portal > Enterprise Applications > ${local.application.display_name}
    2. Go to Provisioning tab
    3. You should now be able to click "Get started"
    4. Set Provisioning Mode to "Automatic"
    5. Configure Admin Credentials:
       - Tenant URL: (Get from Insomnia SCIM panel)
       - Secret Token: (Get from Insomnia SCIM panel)
    6. Test Connection
    7. Save the configuration
    8. Go to Users and groups tab to assign users/groups
    9. Start provisioning from the Provisioning tab
    
    Required elements configured:
    - msiam_access role added (ID: b9632174-c057-4f7e-951b-be3adc52bfe6)
    - User role added (ID: 18d14569-c3bd-439b-9a66-3a2aee01d14f)
    - Service principal tags: WindowsAzureActiveDirectoryCustomSingleSignOnApplication, WindowsAzureActiveDirectoryIntegratedApp
    - App role assignment required: true
EOT
  : "SCIM is not enabled for this application. Set enable_scim = true to enable SCIM support.")
}

output "service_principal_id" {
  value = local.service_principal.id
}

output "app_roles" {
  value = local.app_roles_list
}
