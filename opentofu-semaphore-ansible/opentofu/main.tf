terraform {
    required_version = ">= 1.0"
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.23.0"
        }
    }
}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "minikube"
}

resource "kubernetes_namespace" "opentofu_ansible" {
    metadata {
        name= var.kubernetes_namespace
        labels = {
            app= "opentofu-ansible-integration"
            environment= "development"
            managed-by= "opentofu"
        }
    }
}