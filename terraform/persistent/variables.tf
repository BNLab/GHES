variable "prefix" {
  type        = string
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  description = "Azure Gov region"
  default     = "usgovvirginia"
}

variable "tfstate_storage_account_name" {
  type        = string
  description = "Must be globally unique, 3-24 chars, lowercase alphanumeric only"
}

variable "tags" {
  type    = map(string)
  default = {}
}