resource "digitalocean_droplet" "bastion" {
    image = var.image
    
    name = "bastion-${var.name}-${var.region}"
    
    region = var.region
    
    size = "s-1vcpu-1gb"

    ssh_keys = [data.digitalocean_ssh_key.kaan.id, data.digitalocean_ssh_key.can.id]

    vpc_uuid = digitalocean_vpc.web.id

    tags = ["${var.name}-webserver"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_record" "bastion" {
    domain = data.digitalocean_domain.web.name
    type = "A"
    name = "bastion-${var.name}-${var.region}"
    value = digitalocean_droplet.bastion.ipv4_address
    ttl = 30
}


resource "digitalocean_firewall" "bastion" {
    #the name we give our firewall for ease of use
    name = "${var.name}-ssh-bastion"

    #the droplets to apply this firewall to
    droplet_ids = [digitalocean_droplet.bastion.id]

    # Rules to allow only ssh both inbound from the public internet and only
    # allow outbound ssh traffic into the VPC network. Also allow ping just for
    # eas of use inside the VPC as well
    inbound_rule {
        protocol = "tcp"
        port_range = "22"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "22"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }
    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }
}
