resource "random_uuid" "boundary_token" {
}

// resource "google_service_account" "boundary_controller" {
//   account_id   = "boundary-controller-id"
//   display_name = "Boundary Controller"
// }



// module "boundary_tls_cert" {
//   source  = "devops-rob/tls/gcp"
//   version = "0.1.4"

//   project_id            = var.project_id
//   region                = var.project_region
//   service_account_email = google_service_account.boundary_controller.email
//   tls_bucket            = "boundary-tls"
//   tls_cert_name         = "boundary"
// }

// resource "google_storage_bucket_iam_member" "boundary_controller" {
//   bucket = module.vault.vault_storage_bucket
//   role   = "roles/storage.legacyObjectReader"
//   member = "serviceAccount:${google_service_account.boundary_controller.email}"
// }

resource "google_compute_region_instance_group_manager" "boundary_controller" {
  name = "boundary-controller-group-manager"

  base_instance_name        = "boundary-controller"
  region                    = var.project_region
  distribution_policy_zones = var.instance_zones

  version {
    instance_template = google_compute_instance_template.boundary_controller.id
  }

  target_pools = [google_compute_target_pool.boundary_controller.id]
  target_size  = var.boundary_controller_instance_count

  named_port {
    name = "nomad"
    port = 4646
  }

  named_port {
    name = "https"
    port = 443
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.nomad.self_link
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

resource "google_compute_instance_template" "boundary_controller" {
  name_prefix  = "boundary-controller-"
  machine_type = var.nomad_client_instance_type

  tags = [var.nomad_client_instance_tag, "allow-health-check", "allow-http"]

  disk {
    source_image = var.nomad_client_instance_image
    auto_delete  = true
    disk_size_gb = 20
    boot         = true
  }

  metadata_startup_script = templatefile("${path.module}/scripts/nomad_client.sh", {
    NOMAD_SERVER_TAG         = var.nomad_server_instance_tag
    CONSUL_SERVER_TAG        = var.consul_server_instance_tag
    CONSUL_TOKEN             = random_uuid.consul_token.id
    VAULT_ADDR               = module.vault.vault_addr
    vault_tls_bucket         = module.vault.vault_storage_bucket
    vault_kms_crypto_key     = var.vault_kms_crypto_key
    kms_project              = var.project_id

  })

  can_ip_forward = false
  network_interface {
    network = "default"

    access_config {}
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    #  email  = google_service_account.boundary_controller.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "cloud-platform"]
  }
}

resource "google_compute_target_pool" "boundary_controller" {
  name = "boundary-controller-pool"

  health_checks = [
    google_compute_http_health_check.nomad.name,
  ]
}
