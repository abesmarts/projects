

resource "kubernetes_namespace" "opentofu_ansible" {
    metadata {
        name = var.kubernetes_namespace
        labels = {
            app= "opentofu-ansible-integration"
            environment= "development"
            managed-by= "opentofu"
        }
    }
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

resource "kubernetes_deployment" "ubuntu_vm" {
    metadata {
        name = "unbuntu-vm"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
        labels = {
            app = "ubuntu-vm"
            os = "ubuntu"
            managed-by = "opentofu"
        }
    }
    spec {
        replicas = var.vm_replicas
        selector {
            match_labels = {
                app = "ubuntu-vm"
                os = "ubuntu"
            }
        }
        template {
            metadata {
                labels = {
                    app = "ubuntu-vm"
                    os = "ubuntu"
                }
            }
            spec {
                container {
                    image = "unbuntu:20.04"
                    name = "unbuntu"
                    command = ["/bin/bash", "-c", "apt-get update && apt-get install -y openssh-server sudo python3 && service ssh start && sleep infinity"]
                    env {
                        name = "DEBIAN_FRONTEND"
                        value= "noninteractive"
                    }

                    volume_mount {
                        name = "ssh-keys"
                        mount_path = "/root/.ssh"
                        read_only = true
                    }
                    volume_mount {
                        name = "sansible-config"
                        mount_path = "/etc/ansible"
                        read_only = true
                    }
                    resources {
                        requests = {
                            memory = "256Mi"
                            cpu = "100m"
                        }
                        limits = {
                            memory = "512Mi"
                            cpu = "500m"
                        }
                    }
                }
                
                volume {
                    name = "ansible-config"
                    config_map {
                        name = kubernetes_config_map.ansible_config.metadata[0].name 
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
        labels = {
            app = "centos-vm"
            os = "centos"
            managed-by = "opentofu"
        }
    }
    spec {
        replicas = var.vm_replicas

        selector {
            match_labels = {
                app = "centos-vm"
                os = "centos"
            }
        }
        template {
            metadata {
                labels = {
                    app = "centos-vm"
                    os = "centos"
                }
            }
            spec {
                container {
                    image = "centos:7"
                    name = "centos"
                    command = ["/bin/bash", "-c", "yum update -y && yum install -y openssh-server sudo python3 && ssh-keygen -A && /usr/sbin/sshd -D & sleep infinity"]


                    volume_mount {
                        name = "ssh-keys"
                        mount_path = "/root/.ssh"
                        read_only = true
                    
                        }
                    volume_mount {
                        name = "ansible-config"
                        mount_path = "/etc/ansible"
                        read_only = true
                    
                        }
                    resources {
                        requests = {
                            memory = "256Mi"
                            cpu = "100m"
                        }
                        limits = {
                            memory = "512Mi"
                            cpu = "500m"
                            }
                    }
                }
               
                volume {
                    name = "ansible-config"
                    config_map {
                        name = kubernetes_config_map.ansible_config.metadata[0].name
                    }
                }   
            }
        } 
    }
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