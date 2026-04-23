# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.2.0] - 2026-04-23
- Added `app_roles` (list(string), default `[]`) input to declare multiple app
  roles on a single application in one module call — useful when one Azure AD
  app backs several gateway role checks (e.g. one role per `method:path`
  string consumed by a post-function / Datakit role check).
- `app_role` (string) is now optional (default `null`) and may be combined with
  `app_roles`; values are merged and de-duplicated into an internal effective
  role list. Fully backward-compatible — existing callers setting only
  `app_role` continue to work unchanged.
- `service_principal_roles` now defaults to the full effective role list
  (union of `app_role` and `app_roles`) when left empty. Previously defaulted
  to `[var.app_role]`.
- Added a module precondition that at least one role is declared.

## [2.1.0] - 2026-04-22
- Added support for the client-credentials (M2M) flow via two new variables:
  - `enable_client_credentials` (bool, default `false`) — opt-in switch
  - `service_principal_roles` (list, default `[]`) — roles to self-assign to the
    app's own service principal; defaults to `[var.app_role]` when empty
- When enabled, `azuread_app_role_assignment.service_principal` self-assigns
  the listed roles so M2M tokens issued for this app carry the `roles` claim
- Fixed `versions.tf` to declare the `azuread` provider (the resources used
  are `azuread_*`, not `azurerm_*`)

## [2.0.0] - 2025-05-11
- Removed support for SCIM

## [1.2.0] - 2025-05-11
- Support importing azuread_application and service principal to support SCIM.
## [1.0.2] - 2025-05-11
- Fixed SCIM tags
## [1.0.1] - 2025-05-11
- Fixed SCIM outputs
## [1.0.0] - 2025-05-11
- Added support SCIM

## [0.3.0] - 2025-05-11
- Added support setting the mail property of additional users

## [0.2.0] - 2025-02-05
- Added support for creating users
 - all users must be declared with:
  * Display name
  * Username (including Azure account domain name)
  * Password
  * Role (this gets created as an app role in the OIDC application)

## [0.1.0] - 2025-02-03

### Added
- Support for single app role creation
- Automatic app role assignment to current user
- Random UUID generation for app roles

## [0.0.1] - 2025-02-03

### Added
- Initial release of the Azure AD OIDC Provider module
- Support for creating Azure AD application with OIDC configuration
- Service Principal creation with enterprise feature tags
- Client secret generation
- OIDC metadata endpoints and configuration
- Example implementation
- Make file for easy testing
- Comprehensive documentation
- Support for Azure AD Provider version 3.1.0

### Required Providers
- azuread ~> 3.1.0
- http >= 3.0.0
- random >= 3.0.0

[0.1.0]: https://github.com/username/terraform-azuread-oidc-provider/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/username/terraform-azuread-oidc-provider/releases/tag/v0.0.1
