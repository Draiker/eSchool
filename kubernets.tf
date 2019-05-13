resource "google_container_cluster" "primary" {
  name     = "${var.claster_name}"
  location = "${var.region}"

  remove_default_node_pool = true
  initial_node_count = 1
  
  network                  = "${google_compute_network.eschool_vpc_network.name}"
  subnetwork               = "${google_compute_subnetwork.private_subnetwork.name}"
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.claster_name}-pool"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}


