variable do_token {}

variable region {
    type = string
    default = "nyc3"
}

variable droplet_count {
    type = number
    default = 1
}

variable name { 
    type = string
    default = "ikiler"
}

variable image {
    type = string
    default = "ubuntu-20-04-x64"
}

variable droplet_size {
    type = string
    default = "s-1vcpu-1gb"
}

variable kaan_ssh_key {
    type = string
    default = "Kaan Ubuntu Laptop"
}

variable can_ssh_key {
    type = string
    default = "Can Personal Macbook Pro 2018"
}

variable subdomain {
    type = string
}

variable domain_name {
    type = string
}

variable db_count {
    type = number
    default = 1
}

variable database_size {
    type = string
    default = "db-s-1vcpu-1gb"
}
