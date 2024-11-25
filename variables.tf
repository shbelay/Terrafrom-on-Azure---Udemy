variable "vmName" {
  type = string
  description = "This is the name for the virtual machine"
}

variable "admin_username" {
  type = string
  description = "This is the VM username"
}

variable "vmSize" {
  type = string
  description = "This is the size of the machine"
  default = "Standard_B2s"
}

variable "adminPassword" {
  type = string
  description = "This is the admin password for VM01"
  sensitive = true
}