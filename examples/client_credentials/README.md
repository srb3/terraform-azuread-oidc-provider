# Client Credentials (M2M) Example

Demonstrates the machine-to-machine flow. Tokens issued via `grant_type=client_credentials` carry both the `appid` claim (the client's own ID) and a `roles` claim populated from the service principal's app role assignments.

## Usage

1. Copy this directory to your local environment.
2. Run:
   ```bash
   terraform init
   terraform apply -var="tenant_id=your-tenant-id"
   ```
3. Mint a token and decode it (e.g. via [jwt.ms](https://jwt.ms)):
   ```bash
   terraform output -raw mint_token_curl | bash
   ```

## What the token looks like

```json
{
  "iss": "https://login.microsoftonline.com/{tenant-id}/v2.0",
  "aud": "{client_id}",
  "appid": "{client_id}",
  "roles": ["service.read", "service.write"],
  "exp": ...,
  "iat": ...
}
```

## Notes

- `redirect_uris` is set to `[]` because CC flow doesn't redirect. The module still requires the variable.
- Role values must start with a letter and not contain leading slashes (Azure AD constraint). Use `get:/users` rather than `/users:get`.
- The role assignments are admin-consented automatically by `azuread_app_role_assignment`. No manual consent step needed.

## Requirements

- Azure AD tenant with permissions to create applications and assign app roles
- Terraform >= 1.0.0
- `azuread` provider >= 2.0.0
