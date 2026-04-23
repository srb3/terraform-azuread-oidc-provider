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
  version = "~> 2.2"

  display_name    = "my-m2m-app"
  identifier_uris = ["api://my-m2m-app"]
  redirect_uris   = []  # not used by CC, but variable is required

  # Declare multiple roles in a single call — each value becomes an
  # app role on the application, and (because CC is enabled below) is
  # self-assigned to the SP so M2M tokens carry all of them.
  app_roles = ["service.read", "service.write"]

  enable_client_credentials = true
  # Omit service_principal_roles to default to the full app_roles list.
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

### Single- vs multi-role inputs

| Your situation | What to set |
|---|---|
| Exactly one role on the app | `app_role = "foo"` (legacy, still works) **or** `app_roles = ["foo"]` |
| Multiple roles on one app | `app_roles = ["foo", "bar", ...]` |
| Upgrading an existing v2.1 caller | No change needed. `app_role` still accepted. |
| Existing caller wants to add a role without changing the primary | Keep `app_role = "foo"`, add `app_roles = ["bar"]` — they're unioned |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `display_name` | Display name for the application | `string` | — | yes |
| `identifier_uris` | Identifier URIs (e.g. `api://my-app`) | `list(string)` | — | yes |
| `redirect_uris` | Allowed redirect URIs (can be `[]` for CC-only) | `list(string)` | — | yes |
| `app_role` | Single app role (legacy — prefer `app_roles`). Merged with `app_roles` if both set. | `string` | `null` | no* |
| `app_roles` | List of app roles to create on the application. | `list(string)` | `[]` | no* |
| `users` | Additional users + role assignments (for ROPC / interactive) | `list(object)` | `[]` | no |
| `enable_client_credentials` | Self-assign roles to the SP for M2M flows | `bool` | `false` | no |
| `service_principal_roles` | Roles to self-assign when CC is enabled. Defaults to the full effective role set (union of `app_role` + `app_roles`) when empty. | `list(string)` | `[]` | no |

\* One of `app_role` or `app_roles` must produce a non-empty role set. The module fails at plan time otherwise.

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
