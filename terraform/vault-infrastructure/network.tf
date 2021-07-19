//resource "google_compute_http_health_check" "vault" {
//  name                = "vault-http"
//  port                = 8200
//  request_path        = "/v1/status/leader"
//  check_interval_sec  = 10
//  timeout_sec         = 10
//  healthy_threshold   = 1
//  unhealthy_threshold = 3
//
//}
//
//resource "google_compute_health_check" "vault" {
//  name                = "vault-tcp"
//  check_interval_sec  = 10
//  timeout_sec         = 10
//  healthy_threshold   = 1
//  unhealthy_threshold = 3
//
//  tcp_health_check {
//    port = "8200"
//  }
//}
//
//resource "google_compute_forwarding_rule" "vault_server_internal" {
//  name                  = "vault-server-internal-forwarding-rule"
//  load_balancing_scheme = "INTERNAL"
//  backend_service       = google_compute_region_backend_service.vault_server.id
//
//  all_ports = true
//}
//
//resource "google_compute_region_backend_service" "vault_server" {
//  name          = "vault-server"
//  region        = var.project_region
//  health_checks = [google_compute_health_check.vault.id]
//
//  backend {
//    group = google_compute_region_instance_group_manager.vault_server.instance_group
//  }
//}
