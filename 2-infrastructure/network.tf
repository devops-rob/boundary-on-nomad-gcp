# Consul
resource "google_compute_http_health_check" "consul" {
  name                = "consul-http"
  port                = 8500
  request_path        = "/v1/status/leader"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 3

}

resource "google_compute_health_check" "consul" {
  name                = "consul-tcp"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 3

  tcp_health_check {
    port = "8500"
  }
}

# Nomad
resource "google_compute_http_health_check" "nomad" {
  name                = "nomad-http"
  port                = 4646
  request_path        = "/v1/status/leader"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 3
}

resource "google_compute_health_check" "nomad" {
  name                = "nomad-tcp"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 3

  tcp_health_check {
    port = "4646"
  }
}

resource "google_compute_forwarding_rule" "nomad_server_internal" {
  name                  = "nomad-server-internal-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.nomad_server.id

  all_ports = true
}

resource "google_compute_region_backend_service" "nomad_server" {
  name          = "nomad-server"
  region        = var.project_region
  health_checks = [google_compute_health_check.nomad.id]

  backend {
    group = google_compute_region_instance_group_manager.nomad_server.instance_group
  }
}

resource "google_compute_forwarding_rule" "consul_server_internal" {
  name                  = "consul-server-internal-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.consul_server.id

  all_ports = true
}

resource "google_compute_region_backend_service" "consul_server" {
  name          = "consul-server"
  region        = var.project_region
  health_checks = [google_compute_health_check.consul.id]

  backend {
    group = google_compute_region_instance_group_manager.consul_server.instance_group
  }
}

#
# Load balancer.
#
resource "google_compute_http_health_check" "ingress_http" {
  name                = "ingress-http"
  port                = 80
  request_path        = "/v1/user"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 3
}

resource "google_compute_global_address" "ingress" {
  name = "ingress"
}

resource "google_compute_global_forwarding_rule" "ingress" {
  name       = "ingress"
  target     = google_compute_target_https_proxy.ingress.id
  port_range = "443"
  ip_address = google_compute_global_address.ingress.address
}

resource "google_compute_managed_ssl_certificate" "ingress" {
  name = "ingress"

  managed {
    domains = [google_dns_record_set.nomad_bongo.name, google_dns_record_set.consul_bongo.name]
  }
}

resource "google_compute_target_https_proxy" "ingress" {
  name             = "ingress"
  url_map          = google_compute_url_map.ingress.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ingress.id]
}

resource "google_compute_url_map" "ingress" {
  name            = "ingress"
  default_service = google_compute_backend_service.ingress.id
}

resource "google_compute_backend_service" "ingress" {
  name        = "ingress"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = google_compute_region_instance_group_manager.boundary_controller.instance_group
  }

  health_checks = [google_compute_http_health_check.ingress_http.id]
}
