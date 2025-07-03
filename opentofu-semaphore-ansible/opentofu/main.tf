terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = ">= 2.23.1"
        }
    }
}

provider "docker" {
    host = "unix:///var/run/docker.sock"
}

resource "docker_image" "ubuntu" {
    name = "rastasheep/ubuntu-sshd:22.04"
}

resource "docker_container" "vm1" {
    name = "ansible-vm1"
    image = docker_image.ubuntu.image_id
    command = ["/usr/sbin/sshd", "-D"]
    ports {
        internal = 22
        external = 2222
    }
    env = [
        "ROOT_PASSWORD=toor"
    ]
}