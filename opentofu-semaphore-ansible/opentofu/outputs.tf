output "kubernetes_namespace" {
    description = "The kubernetes namespace where resources are deployed"
    value = kubernetes_namespace.opentofu_ansible.metadata[0].name 
}

output "ubuntu_vm_deployment" {
    description = "Ubuntu VM deployment name"
    value = kubernetes_deployment.ubuntu_vm.metadata[0].name
}

output "centos_vm_deployment" {
    description = "CentOS VM deployment name"
    value = kubernetes_deployment.centos_vm.metadata[0].name
}

output "mysql_service" {
    description = "MySQL service name and port"
    value = var.enable_mysql ? {
        name = kubernetes_service.mysql[0].metadata[0].name
        port = kubernetes_service.mysql[0].spec[0].port[0].port
    } : null
}

output "vm_access_commands" {
    description = " Commands to access the VMs"
    value = {
        ubuntu = "kubectl exec -it -n ${kubernetes_namespace.opentofu_ansible.metadata[0].name} deployment/$ {kubernetes_deployment.ubuntu_vm.metadata[0].name} -- bash"
        centos = "kubectl exec -it -n ${kubernetes_namespace.opentofu_ansible.metadata[0].name} deployment/$ {kubernetes_deployment.centos_vm.metadata[0].name} -- bash"
        
    }
}