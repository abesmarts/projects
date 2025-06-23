resource "kubernetes_secret" "ssh_keys" {
    metadata {
        name = "ssh_keys"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
        labels = {
            app = "opentofu-ansible-integration"
            component = "ssh-keys" 
            managed-by = "opentofu"
        }
    }
    data = {
        "id_rsa" = file("~/.ssh/id_rsa")
        "id_rsa.pub" = file("~/.ssh/id_rsa.pub")
    }
    tpye = "Opaque"
}

resource "kubernetes_secret" "mysql_credentials" {
    count = var.enable_mysql ? 1 : 0

    metadata {
        name = "mysql_credentials"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name 
        labels = {
            app = "opentofu-ansible-integration"
            component = "mysql" 
            managed-by = "opentofu"
        }
    }
    data = {
        "root_password" = var.mysql_root_password
        "database" = var.mysql_database
    }
    type = "Opaque"
}

resource "kubernetes_config_map" "ansible_config" {
    metadata {
        name = "ansible-config"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
        labels = {
            app  = "opentofu-ansible-integration"
            component = "ansible"
            managed-by = "opentofu"
        }
    }
    data = {
        "ansible.cfg" = file("../ansible/ansible.cfg")
    }
}