variable "mysql_root_password" {
    description = "MySQL root Password"
    type = string
    sensitive = true
    default = "password"
}


variable "mysql_database" {
    description = "MySQL database name"
    type = string
    default = "logs"
}

variable "vm_replicas" {
    description = "Number of VM replicas"
    type = number
    default = 1
    validation {
        condition = var.vm_replicas >= 1 && var.vm_replicas <= 5
        error_message = "VM replicas must be between 1 and 5."
    }
}

variable "kubernetes_namespace" {
    description = "Kubernetes namespace for all resources"
    type = string
    default = "opentofu-ansible"
    validation {
        condition = can(regex("^[a-z0-9-]+$",var.kubernetes_namespace))
        error_message = "Namespace must contain only lowercase letters, numbers, and hyphens."
    }
}

variable "enable_mysql" {
    description = "Enable MySQL deployment for state storage"
    type = bool
    default = true
}