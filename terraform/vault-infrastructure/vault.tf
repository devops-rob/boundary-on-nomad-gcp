//resource "google_compute_region_instance_group_manager" "vault_server" {
//  name = "vault-server-group-manager"
//
//  base_instance_name        = "vault-server"
//  region                    = var.project_region
//  distribution_policy_zones = var.instance_zones
//
//  version {
//    instance_template = google_compute_instance_template.vault_server.id
//  }
//
//  target_pools = [google_compute_target_pool.vault_server.id]
//  target_size  = var.vault_server_instance_count
//
//  named_port {
//    name = "http"
//    port = 8200
//  }
//
//  auto_healing_policies {
//    health_check      = google_compute_http_health_check.vault.self_link
//    initial_delay_sec = 300
//  }
//
//  update_policy {
//    type                         = "PROACTIVE"
//    instance_redistribution_type = "PROACTIVE"
//    minimal_action               = "REPLACE"
//    min_ready_sec                = 30
//    replacement_method           = "SUBSTITUTE"
//    max_surge_fixed              = 3
//  }
//}
//
//resource "google_compute_instance_template" "vault_server" {
//  name_prefix  = "consul-server-"
//  machine_type = var.vault_server_instance_type
//
//  tags = [var.vault_server_instance_tag, "allow-health-check"]
//
//  disk {
//    source_image = var.vault_server_instance_image
//    auto_delete  = true
//    disk_size_gb = 20
//    boot         = true
//  }
//
//  metadata_startup_script = templatefile("${path.module}/cloud-init/vault_server.sh", {
//    VAULT_SERVER_COUNT = var.vault_server_instance_count
//    VAULT_SERVER_TAG   = var.vault_server_instance_tag
//  })
//
//  can_ip_forward = false
//  network_interface {
//    network = "default"
//
//    access_config {}
//  }
//
//  lifecycle {
//    create_before_destroy = true
//  }
//
//  service_account {
//    scopes = ["userinfo-email", "compute-ro", "storage-ro", "cloud-platform"]
//  }
//}
//
//resource "google_compute_target_pool" "vault_server" {
//  name = "consul-server-pool"
//
//  health_checks = [
//    google_compute_http_health_check.vault.name,
//  ]
//}


module "vault" {
  source         = "terraform-google-modules/vault/google"
  project_id     = var.project_id
  region         = var.project_region
}
