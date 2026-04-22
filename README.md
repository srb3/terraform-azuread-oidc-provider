# Azure AD OIDC Provider Terraform Module

Configures Azure AD as an OpenID Connect (OIDC) identity provider for use with API gateways and other downstream consumers.

## Features

- Creates an Azure AD application registration + service principal
- Generates a client secret
- Defines app roles (one default + optional per-user roles)
- Optional: creates Azure AD users with role assignments (for ROPC / interactive flows)
- Optional: self-assigns roles to the app's own service principal so machine-to-machine (client-credentials) tokens carry the `roles` claim
- Returns OIDC discovery, issuer, JWKS and token endpoints (both `v2.0` and `sts.windows.net` flavours)

## Supported Flows

| Flow | Use case | Required config |
|---|---|---|
| Authorization code / implicit | Human user logs in via redirect | `redirect_uris`, optionally `users` |
| Resource Owner Password Credentials (ROPC) | Test harness logs in as a created user (non-interactive) | `users` with `password` set |
| Client Credentials (M2M) | Service-to-service; token carries `appid` + `roles` | `enable_client_credentials = true` |

## Quick Start

```hcl
module "oidc_provider" {
  source  = "srb3/oidc-provider/azuread"
  version = "~> 2.1"

  display_name    = "my-oidc-app"
  identifier_uris = ["api://my-oidc-app"]
  redirect_uris   = ["https://my-app.example.com/oauth/callback"]
  app_role        = "kong-admin"
}
```

## Client Credentials (M2M) Flow

Set `enable_client_credentials = true` to make the module self-assign the configured app roles to the application's own service principal. Without this, M2M tokens issued via the client-credentials grant contain `appid` but no `roles` claim — breaking any downstream role-based authorization.

```hcl
module "oidc_provider" {
  source  = "srb3/oidc-provider/azuread"
  version = "~> 2.1"

  display_name    = "my-m2m-app"
  identifier_uris = ["api://my-m2m-app"]
  redirect_uris   = []  # not used by CC, but variable is required
  app_role        = "service.read"

  enable_client_credentials = true
  # Defaults to [var.app_role] when empty. Pass an explicit list to
  # assign multiple roles at once.
  service_principal_roles = ["service.read", "service.write"]
}
```

Mint a token:

```bash
curl -X POST "https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token" \
  -d "grant_type=client_credentials" \
  -d "client_id={client_id}" \
  -d "client_secret={client_secret}" \
  -d "scope={client_id}/.default"
```

The resulting access token will carry `appid: {client_id}` and `roles: ["service.read", "service.write"]`.

> **Azure AD constraint on role values:** values must start with a letter, may contain `a-z A-Z 0-9 _ - . : /`, and must be ≤ 250 chars. Avoid leading slashes — e.g. use `get:/users` rather than `/users:get`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `display_name` | Display name for the application | `string` | — | yes |
| `identifier_uris` | Identifier URIs (e.g. `api://my-app`) | `list(string)` | — | yes |
| `redirect_uris` | Allowed redirect URIs (can be `[]` for CC-only) | `list(string)` | — | yes |
| `app_role` | Default app role created on the application | `string` | — | yes |
| `users` | Additional users + role assignments (for ROPC / interactive) | `list(object)` | `[]` | no |
| `enable_client_credentials` | Self-assign roles to the SP for M2M flows | `bool` | `false` | no |
| `service_principal_roles` | Roles to self-assign when CC is enabled. Defaults to `[var.app_role]` when empty | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `client_id` | Application (client) ID — matches `appid` / `aud` in tokens |
| `client_secret` | Generated client secret (sensitive) |
| `metadata-url` | OIDC discovery URL |
| `issuer` | OIDC issuer (matches `iss` in tokens) |
| `jwks_uri` | JWKS URL — fetched by token validators |
| `token_endpoint` | OAuth2 token endpoint |
| `authorization_endpoint` | OAuth2 authorization endpoint |
| `*_alt` | Same endpoints, but for the `sts.windows.net` issuer (v1 token compatibility) |

## Examples

- [`examples/basic`](./examples/basic) — minimal app registration
- [`examples/additional_users`](./examples/additional_users) — app + multiple users with role assignments (ROPC)
- [`examples/client_credentials`](./examples/client_credentials) — M2M flow with self-assigned SP roles

## Requirements

- Terraform >= 1.0.0
- `azuread` provider >= 2.0.0
- `http` provider >= 3.0.0

## Development

1. Clone the repository
2. Make your changes
3. Run tests:
   - `make test_basic TENANT_ID=your-tenant-id`
   - `make test_additional_users TENANT_ID=... USER_PASSWORD=... DOMAIN=...`
   - `make test_client_credentials TENANT_ID=your-tenant-id`
