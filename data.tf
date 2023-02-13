data "digitalocean_ssh_key" "kaan" {
    name = var.kaan_ssh_key
}

data "digitalocean_ssh_key" "can" {
    name = var.can_ssh_key
}

data "digitalocean_domain" "web" {
    name = var.domain_name
}

data "cloudinit_config" "server_config" {
    gzip = true
    base64_encode = true
    part {
        content_type = "text/cloud-config"
        content = templatefile("${path.module}/cloud-config.yaml", {
            nginx-config: data.local_file.nginx_config.content,
            region: var.region,
        })
    }
}

data "local_file" "nginx_config" {
    filename = "${path.module}/nginx.conf"
}