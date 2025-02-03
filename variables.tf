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
