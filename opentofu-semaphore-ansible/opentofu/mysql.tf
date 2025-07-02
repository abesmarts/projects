resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
    count = var.enable_mysql ? 1 : 0 
    metadata {
        name = "mysql-pv-claim"
        namespace = kubernetes_namespace.opentofu-ansible-integration.metadata[0].name 
        labels = {
            app = "mysql"
            managed-by = "opentofu"
        }
    }
    spec {
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "2Gi"
            }
        }
    }
}

resource "kubernetes_deployment" "mysql" {
    count = var.enable_mysql ? 1 : 0

    metadata {
        name = "mysql"
        namespace = kubernetes_namespace.opentofu-ansible-integration.metadata[0].name 
        labels = {
            app = "mysql"
            managed-by = "opentofu"
        }
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
                labels = {
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
                                name = kubernetes_secret.mysql-credentials[0].metadata[0].name
                                key = "root-password"
                            }
                        }
                    }
                    env {
                        name = "MYSQL_DATABASE"
                        value_from {
                            secret_key_ref {
                                name = kubernetes_secret.mysql-credentials[0].metadata[0].name
                                key = "database"
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
                    resources {
                        requests = {
                            memory = "512Mi"
                            cpu = "250m"
                        }
                        limits = {
                            memory = "1Gi"
                            cpu = "500m"
                        }
                    }
                }

                volume {
                    name = "mysql-persistent-storage"
                    persistent_volume_claim {
                        claim_name = kubernetes_persistent_volume_claim.mysql_pvc[0].metadata[0].name
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "mysql" {
    metadata {
        name = "mysql"
        namespace = kubernetes_namespace.opentofu-ansible-integration.metadata[0].name
        labels = {
            app = "mysql"
            managed-by = "opentofu"
        }
    }
    spec {
        selector = {
            app = "mysql"
        }
        port {
            port = 3306
            target_port = 3306
            name = "mysql"
        }
        type = "ClusterIP"
    }
}