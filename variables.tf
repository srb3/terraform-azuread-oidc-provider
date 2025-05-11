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
