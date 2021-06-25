# ---------------------------------------------------
# Create VPC, subnets, and networking configurations
# ---------------------------------------------------

resource "google_compute_network" "vpc_network" {
  name                    = "boundary"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "pub-subnet-1" {
  name          = "pub-subnet-1"
  ip_cidr_range = "10.1.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "pub-subnet-2" {
  name          = "pub-subnet-2"
  ip_cidr_range = "10.1.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "pub-subnet-3" {
  name          = "pub-subnet-3"
  ip_cidr_range = "10.1.3.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "priv-subnet-1" {
  name          = "priv-subnet-1"
  ip_cidr_range = "10.1.4.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "priv-subnet-2" {
  name          = "priv-subnet-2"
  ip_cidr_range = "10.1.5.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "priv-subnet-3" {
  name          = "priv-subnet-3"
  ip_cidr_range = "10.1.6.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_global_address" "db-ip-address-range" {
  name          = "db-ip-address-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db-ip-address-range.name]
}