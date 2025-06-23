resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
    metadata {
        name = "mysql-pv-claim"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name 
    }
    spec {
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "1Gi"
            }
        }
    }
}

resource "kubernetes_deployment" "mysql" {
    metadata {
        name = "mysql"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name 
    }
    spec {
        selector {
            match_labels = {
                app = "mysql"
            }
        }
        strategy {
            type = "Recreate"
        }
        template {
            metadata {
                labels {
                    app = "mysql"
                }
            }
            spec {
                container {
                    image = "mysql:8"
                    name = "mysql"
                    env {
                        name = "MYSQL_ROOT_PASSWORD"
                        value_from {
                            secret_key_ref {
                                name = kubernetes_secret.mysql_secret.metadata[0].name
                                key = "password"
                            }
                        }
                    }
                    port {
                        container_port = 3306
                        name = "mysql"
                    }
                    volume_mount {
                        name = "mysql-persistent-storage"
                        mount_path = "/var/lib/mysql"
                    }
                }
                volume {
                    name = "mysql-persistent-storage"
                    persistent_volume_claim {
                        claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata[0].name
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "mysql" {
    metadata {
        name = "mysql"
        namespace = kubernetes_namespace.opentofu_ansible.metadata[0].name
    }
    spec {
        selector = {
            app = "mysql"
        }
        port {
            port = 3306
            target_port = 3306
        }
    }
}