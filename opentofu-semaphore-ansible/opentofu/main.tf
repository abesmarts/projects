terraform {
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
        name="opentofu-ansible"
        labels = {
            app = "opentofu-ansible-integration"
        }
    }
}