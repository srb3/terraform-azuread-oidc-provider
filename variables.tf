variable "display_name" {
  type        = string
  description = "Display name for the application"
}

variable "identifier_uris" {
  type        = list(string)
  description = "List of identifier URIs"
}

variable "redirect_uris" {
  type        = list(string)
  description = "List of allowed redirect URIs"
}

variable "app_role" {
  type        = string
  description = "A single app role to create. Retained for backward compatibility; prefer `app_roles` for new callers. If both are set they are merged and de-duplicated."
  default     = null
}

variable "app_roles" {
  type        = list(string)
  description = "App roles to create on the application. Use this for multi-role setups where one app needs to back several downstream authorization decisions (e.g. several route-scoped role strings consumed by API-gateway role checks). Merged with `app_role` and de-duplicated. At least one of `app_role` or `app_roles` must produce a non-empty role set."
  default     = []
}

variable "users" {
  type = list(object({
    username     = string
    role         = string
    password     = optional(string)
    display_name = string
    email        = optional(string)  # Add this line
  }))
  description = "List of additional users and their roles to assign"
  default     = []
}

variable "enable_client_credentials" {
  type        = bool
  description = "If true, assign app roles to this application's own service principal so that client-credentials (M2M) tokens issued for it carry the roles claim. The token's appid will be this application's client_id."
  default     = false
}

variable "service_principal_roles" {
  type        = list(string)
  description = "App role values to assign to this app's own service principal for the client-credentials flow. Each value must be defined as an app role on the application (i.e. appear in `app_role`, `app_roles`, or `users[*].role`). Defaults to the full effective `app_roles` list (union of `app_role` and `app_roles`) when empty. Only used when `enable_client_credentials = true`."
  default     = []
}
