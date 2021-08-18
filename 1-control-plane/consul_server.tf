resource "google_service_account" "consul_server" {
  account_id   = "consul-server-id"
  display_name = "Consul Server"
}

module "consul_tls_cert" {
  source  = "devops-rob/tls/gcp"
  version = "0.1.4"

  project_id            = var.project_id
  region                = var.project_region
  service_account_email = google_service_account.consul_server.email
  tls_bucket            = "consul-tls"
  tls_cert_name         = "consul"
}

resource "google_storage_bucket_iam_member" "consul_server" {
  bucket = module.vault.vault_storage_bucket
  role = "roles/storage.legacyObjectReader"
  member = google_service_account.consul_server.email
}


resource "google_compute_region_instance_group_manager" "consul_server" {
  name = "consul-server-group-manager"

  base_instance_name        = "consul-server"
  region                    = var.project_region
  distribution_policy_zones = var.instance_zones

  version {
    instance_template = google_compute_instance_template.consul_server.id
  }

  target_pools = [google_compute_target_pool.consul_server.id]
  target_size  = var.consul_server_instance_count

  named_port {
    name = "http"
    port = 8500
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.consul.self_link
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    min_ready_sec                = 30
    replacement_method           = "SUBSTITUTE"
    max_surge_fixed              = 3
  }
}

resource "google_compute_instance_template" "consul_server" {
  name_prefix  = "consul-server-"
  machine_type = var.consul_server_instance_type

  tags = [var.consul_server_instance_tag, "allow-health-check"]

  disk {
    source_image = var.consul_server_instance_image
    auto_delete  = true
    disk_size_gb = 20
    boot         = true
  }

  metadata_startup_script = templatefile("${path.module}/scripts/consul_server.sh", {
    CONSUL_SERVER_COUNT              = var.consul_server_instance_count
    CONSUL_SERVER_TAG                = var.consul_server_instance_tag
    CONSUL_MASTER_TOKEN              = var.consul_master_token
    CONSUL_TOKEN_NOMAD_SERVER        = random_uuid.consul_token.id
    consul_tls_bucket                = module.consul_tls_cert.bucket_id
    consul_ca_cert_filename          = module.consul_tls_cert.ca_filename
    consul_tls_cert_filename         = module.consul_tls_cert.cert_filename
    consul_tls_key_filename          = module.consul_tls_cert.key_filename
    kms_project                      = var.project_id
    consul_kms_crypto_key            = module.consul_tls_cert.key_id
    CONSUL_TOKEN_BOUNDARY_CONTROLLER = random_uuid.boundary_token.id
  })

  can_ip_forward = false
  network_interface {
    network = "default"

    //    access_config {}
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    email = google_service_account.consul_server.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "cloud-platform"]
  }
}

resource "google_compute_target_pool" "consul_server" {
  name = "consul-server-pool"

  health_checks = [
    google_compute_http_health_check.consul.name,
  ]
}
