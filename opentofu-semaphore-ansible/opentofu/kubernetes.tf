resource "kubernetes_secret" "ssh_keys" {
    metadata {
        name = "ssh_keys"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
    }
    data = {
        "id_rsa" = file("~/.ssh/id_rsa")
        "id_rsa.pub" = file("~/.ssh/id_rsa.pub")
    }
    tpye = "Opaque"
}

resource "kubernetes_secret" "mysql_secret" {
    metadata {
        name = "mysql-secret"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name 
    }
    data = {
        password = var.mysql_root_password
    }
    type = "kubernetes.io/basic-auth"
}