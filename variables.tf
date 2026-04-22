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
  description = "The name of the app role to create. This will be used for description, display_name and value."
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
  description = "App role values to assign to this app's own service principal for the client-credentials flow. Each value must be defined as an app role on the application (i.e. equal to var.app_role or one of var.users[*].role). Defaults to [var.app_role] when empty. Only used when var.enable_client_credentials = true."
  default     = []
}
