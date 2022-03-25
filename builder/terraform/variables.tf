variable "builder_rg_name" {
  default = "builder"
}

variable "images_rg_name" {
  default = "images"
}

variable "location" {
  default = "westus3"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  default = "Password#1234"
}
