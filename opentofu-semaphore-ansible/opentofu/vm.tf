resource "kubernetes_deployment" "unbuntu_vm" {
    metadata {
        name = "unbuntu-vm"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
    }
    spec {
        replicas = 1
        selector {
            match_labels = {
                app = "ubuntu-vm"
            }
            port {
                port = 22
                target_port = 22
                node_port =  30222
            }
            type = "NodePort"
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
                }
            }
        } 
    }
}