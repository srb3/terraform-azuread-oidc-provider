# Azure AD OIDC Provider Terraform Module

This module configures Azure AD to act as an OpenID Connect (OIDC) identity provider with optional SCIM provisioning support.

## Features

- Creates Azure AD application registration with OIDC configuration
- Sets up service principal and client secret
- Provides OIDC endpoints and metadata URLs
- Configures implicit grant flow with ID tokens
- Creates and manages Azure AD users
- Configures app roles and role assignments
- **NEW**: Optional SCIM provisioning support for enterprise SSO

## Usage

### Basic OIDC Configuration

```hcl
module "oidc_provider" {
  source = "path/to/module"
  
  display_name = "my-oidc-app"
  identifier_uris = [
    "https://my-app.example.com"
  ]
  redirect_uris = [
    "https://my-app.example.com/oauth/callback"
  ]
  app_role = "default-role"
  users = []
}
```

### OIDC with User Management

```hcl
module "oidc_provider" {
  source = "path/to/module"
  
  display_name = "my-oidc-app"
  identifier_uris = [
    "https://my-app.example.com"
  ]
  redirect_uris = [
    "https://my-app.example.com/oauth/callback"
  ]
  app_role = "default-role"
  
  users = [
    {
      username     = "user1@example.com"
      role         = "admin"
      password     = "SecurePassword123!"
      display_name = "User One"
      email        = "user1@example.com"
    },
    {
      username     = "user2@example.com"
      role         = "member"
      password     = "SecurePassword456!"
      display_name = "User Two"
      email        = "user2@example.com"
    }
  ]
}
```

## SCIM Provisioning Support

To enable SCIM provisioning (e.g., for Insomnia Enterprise), you need to create the Azure AD application from a gallery template first, then manage it with Terraform.

### Prerequisites for SCIM

SCIM provisioning requires an Azure AD gallery application template. This cannot be created directly through Terraform due to Azure AD limitations.

### Step-by-Step SCIM Setup

1. **Create Gallery App with SCIM Support**

   Run this script to create a gallery application:

   ```bash
   #!/bin/bash
   # create-scim-app.sh
   
   TEMPLATE_ID="8adf8e6e-67b2-4cf2-a259-e3dc5476c621"
   APP_NAME="my-app-scim-$RANDOM"
   
   # Create the application from gallery template
   RESPONSE=$(az rest --method POST \
     --uri "https://graph.microsoft.com/v1.0/applicationTemplates/$TEMPLATE_ID/instantiate" \
     --headers "Content-Type=application/json" \
     --body "{\"displayName\": \"$APP_NAME\"}")
   
   echo "Waiting for application creation..."
   sleep 15
   
   # Get the application details
   APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)
   APP_OBJECT_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].id" -o tsv)
   SP_ID=$(az ad sp list --display-name "$APP_NAME" --query "[0].id" -o tsv)
   
   echo "Gallery app created!"
   echo "Application Client ID: $APP_ID"
   echo "Application Object ID: $APP_OBJECT_ID"
   echo "Service Principal ID: $SP_ID"
   ```

2. **Import into Terraform**

   After running the script, import the created resources:

   ```bash
   terraform import module.oidc_provider.azuread_application.oidc <APP_OBJECT_ID>
   terraform import module.oidc_provider.azuread_service_principal.oidc <SP_ID>
   ```

3. **Configure with Terraform**

   Now use the module with SCIM enabled:

   ```hcl
   module "oidc_provider" {
     source = "path/to/module"
     
     display_name = "my-scim-app"
     identifier_uris = [
       "https://my-app.example.com"
     ]
     redirect_uris = [
       "https://my-app.example.com/oauth/callback"
     ]
     app_role = "default-role"
     
     # Enable SCIM
     enable_scim = true
     scim_notification_email = "admin@example.com"
     
     # Users to provision
     users = [
       {
         username     = "user1@example.com"
         role         = "member"
         password     = "SecurePassword123!"
         display_name = "User One"
       }
     ]
   }
   ```

4. **Complete SCIM Configuration**

   After Terraform applies:
   - Go to Azure Portal > Enterprise Applications > Your App
   - Navigate to Provisioning tab
   - Click "Get started"
   - Configure with SCIM endpoint and token from your application
   - Test connection and save

## Requirements

- Terraform >= 1.9.0
- AzureAD Provider >= 3.1.0
- HTTP Provider >= 3.4.5
- Random Provider >= 3.0.0

## Providers

| Name | Version |
|------|---------|
| azuread | >= 3.1.0 |
| http | >= 3.4.5 |
| random | >= 3.0.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| display_name | Display name for the application | string | yes |
| identifier_uris | List of identifier URIs | list(string) | yes |
| redirect_uris | List of allowed redirect URIs | list(string) | yes |
| app_role | The name of the app role to create | string | yes |
| users | List of users and their roles | list(object) | no |
| enable_scim | Enable SCIM provisioning support | bool | no |
| scim_notification_email | Email for SCIM notifications | string | no |

## Outputs

| Name | Description |
|------|-------------|
| application | The complete Azure AD application resource |
| client_id | The client ID (application ID) |
| client_secret | The generated client secret (sensitive) |
| metadata-url | The OIDC metadata URL |
| token_endpoint | The OAuth2 token endpoint |
| authorization_endpoint | The OAuth2 authorization endpoint |
| jwks_uri | The JWKS endpoint URL |
| issuer | The OIDC issuer URL |
| service_principal_id | The service principal object ID |
| app_roles | List of configured app roles |
| scim_enabled | Whether SCIM is enabled |
| scim_configuration_instructions | Instructions for completing SCIM setup |

## Examples

See the [examples](./examples) directory for working examples:
- [Basic OIDC](./examples/basic) - Simple OIDC configuration
- [OIDC with Users](./examples/additional_users) - OIDC with user management
- [SCIM Enabled](./examples/scim) - OIDC with SCIM provisioning

## Development

1. Clone the repository
2. Make your changes
3. Run tests:
   - Basic: `make test_basic TENANT_ID=your-tenant-id`
   - With users: `make test_additional_users TENANT_ID=your-tenant-id USER_PASSWORD=password-for-users DOMAIN=azure-ad-domain`
   - SCIM: First run the gallery app script, then: `make test_scim TENANT_ID=your-tenant-id`

## Troubleshooting SCIM

If the "Get started" button doesn't appear in the Provisioning tab:
1. Verify the app was created from the gallery template
2. Check that `enable_scim = true` is set
3. Ensure the service principal has the correct tags
4. Confirm the `msiam_access` app role exists
