data "digitalocean_ssh_key" "kaan" {
    name = var.kaan_ssh_key
}

data "digitalocean_ssh_key" "can" {
    name = var.can_ssh_key
}

data "digitalocean_domain" "web" {
    name = var.domain_name
}