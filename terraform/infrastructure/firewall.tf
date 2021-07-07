<<<<<<< HEAD
//resource "google_compute_firewall" "allow_health_check" {
//  name    = "allow-health-check"
//  network = "default"
//
//  allow {
//    protocol = "tcp"
//    ports    = ["4646", "8500", "80"]
//  }
//
//  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
//  target_tags   = ["allow-health-check"]
//}
//
//
//resource "google_compute_firewall" "allow_http" {
//  name    = "allow-http"
//  network = "default"
//
//  allow {
//    protocol = "tcp"
//    ports    = ["80"]
//  }
//
//  source_ranges = ["0.0.0.0/0"]
//  target_tags   = ["allow-http"]
//}
//
//resource "google_compute_firewall" "nomad_allow_whitelist" {
//  name    = "nomad-allow-whitelist"
//  network = "default"
//
//  allow {
//    protocol = "tcp"
//    ports    = ["4646"]
//  }
//
//  source_ranges = var.whitelist
//  target_tags   = [var.nomad_server_instance_tag]
//}
//
//resource "google_compute_firewall" "consul_allow_whitelist" {
//  name    = "consul-allow-whitelist"
//  network = "default"
//
//  allow {
//    protocol = "tcp"
//    ports    = ["8500"]
//  }
//
//  source_ranges = var.whitelist
//  target_tags   = [var.consul_server_instance_tag]
//}
=======
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["4646", "8500", "80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
}


resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}

resource "google_compute_firewall" "nomad_allow_whitelist" {
  name    = "nomad-allow-whitelist"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["4646"]
  }

  source_ranges = var.whitelist
  target_tags   = [var.nomad_server_instance_tag]
}

resource "google_compute_firewall" "consul_allow_whitelist" {
  name    = "consul-allow-whitelist"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8500"]
  }

  source_ranges = var.whitelist
  target_tags   = [var.consul_server_instance_tag]
}
>>>>>>> 614121036986da1378ab8e9d7cde0c3deef34237
