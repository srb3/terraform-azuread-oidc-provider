# Azure AD OIDC Provider Terraform Module

This module configures Azure AD to act as an OpenID Connect (OIDC) identity provider.

## Features

- Creates Azure AD application registration with OIDC configuration
- Sets up service principal and client secret
- Provides OIDC endpoints and metadata URLs
- Configures implicit grant flow with ID tokens

## Usage

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
}
```

## Requirements

- Terraform >= 1.0.0
- AzureAD Provider >= 2.0.0
- HTTP Provider >= 3.0.0

## Providers

| Name | Version |
|------|---------|
| azuread | >= 2.0.0 |
| http | >= 3.0.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| display_name | Display name for the application | string | yes |
| identifier_uris | List of identifier URIs | list(string) | yes |
| redirect_uris | List of allowed redirect URIs | list(string) | yes |

## Outputs

| Name | Description |
|------|-------------|
| client_id | The client ID (application ID) |
| client_secret | The generated client secret |
| metadata-url | The OIDC metadata URL |
| token_endpoint | The OAuth2 token endpoint |
| authorization_endpoint | The OAuth2 authorization endpoint |
| jwks_uri | The JWKS endpoint URL |
| issuer | The OIDC issuer URL |

## Example

See the [example's](./examples) directory for working examples.

## Development

1. Clone the repository
2. Make your changes
3. Run tests: `make test_basic TENANT_ID=your-tenant-id`
3. Run tests: `make test_additional_users TENANT_ID=your-tenant-id USER_PASSWORD=password-for-users-being-created DOMAIN=you-azure-ad-domain`
