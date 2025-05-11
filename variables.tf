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

variable "enable_scim" {
  description = "Enable SCIM provisioning support for the application"
  type        = bool
  default     = false
}

variable "scim_notification_email" {
  description = "Email address for SCIM provisioning notifications"
  type        = string
  default     = ""
}

variable "import_existing_app" {
  description = "Import an existing gallery application"
  type        = bool
  default     = false
}

variable "existing_client_id" {
  description = "Client ID (Application ID) of existing application"
  type        = string
  default     = ""
}

variable "existing_app_object_id" {
  description = "Object ID of existing application to import"
  type        = string
  default     = ""
}

variable "existing_sp_object_id" {
  description = "Object ID of existing service principal to import"
  type        = string
  default     = ""
}
