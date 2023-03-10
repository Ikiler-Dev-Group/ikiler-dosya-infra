resource "digitalocean_droplet" "web" {
    count = var.droplet_count
    
    image = var.image
    
    name = "web-${var.name}-${var.region}-${count.index + 1}"
    
    region = var.region
    
    size = var.droplet_size

    ssh_keys = [data.digitalocean_ssh_key.kaan.id, data.digitalocean_ssh_key.can.id]

    vpc_uuid = digitalocean_vpc.web.id

    tags = ["${var.name}-webserver"]

    user_data = <<EOF
    #cloud-config
    packages:
        - nginx
        - postgresql
        - postgresql-contrib
    runcmd:
        - [sh, -xc, "echo '<h1>web-${var.region}-${count.index + 1}</h1>' >> var/www/html/index.html"]
    EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_certificate" "web" {
    name = "${var.name}-certificate"
    type = "lets_encrypt"
    domains = ["${var.subdomain}.${data.digitalocean_domain.web.name}"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_loadbalancer" "web" {
    name = "web-${var.region}"
    region = var.region
    droplet_ids = digitalocean_droplet.web.*.id

    vpc_uuid = digitalocean_vpc.web.id

    redirect_http_to_https = true

    forwarding_rule {
        entry_port = 443
        entry_protocol = "https"

        target_port = 80
        target_protocol = "http"

        certificate_name = digitalocean_certificate.web.name
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_firewall" "web" {
    #the name we give our firewall for ease of use
    name = "${var.name}-vpc-traffic"

    #the droplets to apply this firewall to
    droplet_ids = digitalocean_droplet.web.*.id

    #Internal VPC Rules. We have to let ourselves talk to each other
    inbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }
    inbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }
    inbound_rule {
        protocol = "icmp"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }
    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }
    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    #Selective Outbound Traffic Rules
    #DNS
    outbound_rule {
        protocol = "udp"
        port_range = "53"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
    #HTTP
    outbound_rule {
        protocol = "tcp"
        port_range = "80"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
    #HTTPS
    outbound_rule {
        protocol = "tcp"
        port_range = "443"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
    #ICMP (Ping)
    outbound_rule {
        protocol = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
}

resource "digitalocean_record" "web" {
    domain = data.digitalocean_domain.web.name
    type = "A"
    name = var.subdomain
    value = digitalocean_loadbalancer.web.ip
    ttl = 30
}