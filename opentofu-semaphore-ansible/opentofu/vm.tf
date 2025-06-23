resource "kubernetes_deployment" "unbuntu_vm" {
    metadata {
        name = "unbuntu-vm"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
    }
    spec {
        replicas = var.vm_replicas
        selector {
            match_labels = {
                app = "ubuntu-vm"
            }
        }
        template {
            metadata {
                labels = {
                    app = "ubuntu-vm"
                }
            }
            spec {
                container {
                    image = "unbuntu:20.04"
                    name = "unbuntu"
                    command = ["/bin/bash", "-c", "sleep infinity"]

                    volume_mount {
                        name = "ssh-keys"
                        mount_path = "/root/.ssh"
                        read_only = true
                    }
                }
                volume {
                    name = "ssh-keys"
                    secret{
                        secret_name = kubernetes_secret.ssh_keys.metadata[0].name
                    }
                }
            }
        }
    }
}

resource "kubernetes_deployment" "centos_vm" {
    metadata {
        name = "centos_vm"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
    }
    spec {
        replicas = 1
        selector {
            match_labels = {
                app = "centos-vm"
            }
        }
        template {
            metadata {
                labels = {
                    app = "centos-vm"
                }
            }
            spec {
            container {
                image = "centos:7"
                name = "centos"
                command = ["/bin/bash", "-c", "sleep infinity"]

                volume_mount {
                    name = "ssh-keys"
                    mount_path = "/root/.ssh"
                    read_only = true
                
                    }
                }
             volume {
                name = "ssh-keys"
                secret {
                    secret_name = kubernetes_secret.ssh_keys.metadata[0].name
                }
             }   
            }
        } 
    }
}