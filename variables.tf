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
