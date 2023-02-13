resource "digitalocean_vpc" "web" {
    name = "ikiler-vpc"
    region = var.region
    ip_range = "192.168.44.0/24"
}