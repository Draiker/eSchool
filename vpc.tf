
//Network config
resource "google_compute_network" "eschool_vpc_network" {
  name = "eschool-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnetwork" {
  name          = "private-subnetwork"
  ip_cidr_range = "${var.ip_cidr_range_private}"
  region        = "${var.region}"
  network       = "${google_compute_network.eschool_vpc_network.self_link}"
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  count  = 0
  name    = "router"

  region  = "${google_compute_subnetwork.private_subnetwork.region}"
  network = "${google_compute_network.eschool_vpc_network.self_link}"

  bgp {
    asn = 64514
  }
}

# resource "google_compute_router_nat" "simple-nat" {
#   name = "nat-1"
#   router = "${google_compute_router.router.name}"
#   region = "${var.region}"
#   nat_ip_allocate_option = "MANUAL_ONLY"
#   nat_ips = ["${google_compute_address.address.*.self_link}"]
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
# }

// Reserve static IP address
resource "google_compute_global_address" "my_global_address" {
    name   = "ip-global-address"
}
# resource "google_compute_address" "address" {
#   count  = "${var.countnat}"
#   name   = "ip-external-address"
#   region = "${var.region}"
# }

//DNS rules
resource "google_dns_record_set" "eschool_app_subdomain" {
  name          = "${var.app_subdomain}.${google_dns_managed_zone.eschool_app.dns_name}"
  managed_zone  = "${google_dns_managed_zone.eschool_app.name}"
  type          = "A"
  ttl           = 300

  rrdatas = ["${google_compute_global_address.my_global_address.address}"]
}

resource "google_dns_record_set" "ci_server_domain" {
  name          = "${google_dns_managed_zone.eschool_app.dns_name}"
  managed_zone  = "${google_dns_managed_zone.eschool_app.name}"
  type          = "A"
  ttl           = 300

  rrdatas = ["${google_compute_instance.ciserver.*.network_interface.0.access_config.0.nat_ip}"]
}

resource "google_dns_managed_zone" "eschool_app" {
  name     = "eschool-zone"
  dns_name = "${var.dns_zone}."
}

//Firewall rules
resource "google_compute_firewall" "ssh_firewall" {
  name    = "allow-ssh"
  network = "${google_compute_network.eschool_vpc_network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["ssh"]
}

resource "google_compute_firewall" "sonar_firewall" {
  name    = "allow-sonar"
  network = "${google_compute_network.eschool_vpc_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["sonar"]
}

resource "google_compute_firewall" "web_firewall" {
  name    = "allow-web"
  network = "${google_compute_network.eschool_vpc_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["web"]
}