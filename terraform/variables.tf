variable "prefix" {
  type        = string
  description = "Prefix used for resource names"
}

variable "location" {
  type        = string
  description = "Azure region (Gov), e.g. usgovvirginia"
  default     = "usgovvirginia"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "address_space" {
  type        = list(string)
  default     = ["10.50.0.0/16"]
}

variable "vm_subnet_cidr" {
  type        = string
  default     = "10.50.10.0/24"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key contents"
}

variable "vm_size" {
  type        = string
  description = "GHES recommended sizes vary by user count; start with something like Standard_D4s_v5 if available"
  default     = "Standard_D8s_v3"
}

# Optional: pin a specific marketplace version if you want stability
variable "ghes_image_version" {
  type        = string
  default     = "3.19.0"
}
