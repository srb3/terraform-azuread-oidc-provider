# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
