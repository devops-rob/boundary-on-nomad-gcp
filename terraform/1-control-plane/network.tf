//resource "google_compute_http_health_check" "vault" {
//  name                = "consul-http"
//  port                = 8500
//  request_path        = "/v1/status/leader"
//  check_interval_sec  = 10
//  timeout_sec         = 10
//  healthy_threshold   = 1
//  unhealthy_threshold = 3
//
//}
//
//resource "google_compute_health_check" "vault" {
//  name                = "consul-tcp"
//  check_interval_sec  = 10
//  timeout_sec         = 10
//  healthy_threshold   = 1
//  unhealthy_threshold = 3
//
//  tcp_health_check {
//    port = "8200"
//  }
//}