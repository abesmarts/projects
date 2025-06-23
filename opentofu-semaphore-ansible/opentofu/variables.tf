variable "mysql_root_password" {
    description = "MySQL root Password"
    type = string
    sensitive = true
    default = "password"
}

variable "vm_replicas" {
    description = "Number of VM replicas"
    type = Number
    default = 1
}

variable "kubernetes_namespace" {
    description = "Kubernetes namespace for resources"
    type = string
    default = "opentofu-ansible"
}