resource "digitalocean_database_cluster" "postgres-cluster" {
    name = "${var.name}-database-cluster"
    engine = "pg"
    version = "11"
    size = var.database_size
    region = var.region
    node_count = var.db_count
    private_network_uuid = digitalocean_vpc.web.id
}

resource "digitalocean_database_firewall" "posrgres-cluster-firewall" {
    cluster_id = digitalocean_database_cluster.postgres-cluster.id
    rule {
        type = "tag" 
        value = "${var.name}-webserver"
    }
}