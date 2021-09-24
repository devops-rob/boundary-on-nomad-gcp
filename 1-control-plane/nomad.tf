resource "random_uuid" "consul_token" {
}

resource "random_uuid" "vault_token" {
}

resource "google_service_account" "nomad_server" {
  account_id   = "nomad-server-id"
  display_name = "Nomad Server"
}

module "nomad_tls_cert" {
  source  = "devops-rob/tls/gcp"
  version = "0.1.4"

  project_id            = var.project_id
  region                = var.project_region
  service_account_email = google_service_account.nomad_server.email
  tls_bucket            = "nomad-tls"
  tls_cert_name         = "nomad"
}

resource "google_storage_bucket_iam_member" "nomad_server" {
  bucket = module.vault.vault_storage_bucket
  role   = "roles/storage.legacyObjectReader"

  member = "serviceAccount:${google_service_account.nomad_server.email}"
}

resource "google_kms_crypto_key_iam_member" "nomad_vault" {
  crypto_key_id = data.google_kms_crypto_key.vault.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${google_service_account.nomad_server.email}"
}

resource "google_kms_crypto_key_iam_member" "nomad_consul" {
  crypto_key_id = module.consul_tls_cert.key_id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${google_service_account.nomad_server.email}"
}


resource "google_compute_region_instance_group_manager" "nomad_server" {
  name = "nomad-server-group-manager"

  base_instance_name        = "nomad-server"
  region                    = var.project_region
  distribution_policy_zones = var.instance_zones

  version {
    instance_template = google_compute_instance_template.nomad_server.id
  }

  target_pools = [google_compute_target_pool.nomad_server.id]
  target_size  = var.nomad_server_instance_count

  named_port {
    name = "http"
    port = 4646
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

resource "google_compute_instance_template" "nomad_server" {
  name_prefix  = "nomad-server-"
  machine_type = var.nomad_server_instance_type

  tags = [var.nomad_server_instance_tag, "allow-health-check"]

  disk {
    source_image = var.nomad_server_instance_image
    auto_delete  = true
    disk_size_gb = 20
    boot         = true
  }

  metadata_startup_script = templatefile("${path.module}/scripts/nomad_server.sh", {
    CONSUL_SERVER_TAG        = var.consul_server_instance_tag
    CONSUL_TOKEN             = random_uuid.consul_token.id
    consul_tls_bucket        = module.consul_tls_cert.bucket_id
    consul_ca_cert_filename  = module.consul_tls_cert.ca_filename
    consul_tls_cert_filename = module.consul_tls_cert.cert_filename
    consul_tls_key_filename  = module.consul_tls_cert.key_filename
    consul_kms_crypto_key    = module.consul_tls_cert.key_id

    NOMAD_SERVER_COUNT      = var.nomad_server_instance_count
    NOMAD_SERVER_TAG        = var.nomad_server_instance_tag
    nomad_tls_bucket        = module.nomad_tls_cert.bucket_id
    nomad_ca_cert_filename  = module.nomad_tls_cert.ca_filename
    nomad_tls_cert_filename = module.nomad_tls_cert.cert_filename
    nomad_tls_key_filename  = module.nomad_tls_cert.key_filename
    nomad_kms_crypto_key    = module.nomad_tls_cert.key_id

    VAULT_ADDR              = module.vault.vault_addr
    vault_ca_cert_filename  = var.vault_ca_cert_filename
    vault_tls_cert_filename = var.vault_tls_cert_filename
    vault_tls_key_filename  = var.vault_tls_key_filename
    vault_tls_bucket        = module.vault.vault_storage_bucket
    vault_kms_crypto_key    = var.vault_kms_crypto_key
    VAULT_TOKEN             = random_uuid.vault_token.id

    kms_project = var.project_id

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
    email  = google_service_account.nomad_server.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "cloud-platform"]
  }
}

resource "google_compute_target_pool" "nomad_server" {
  name = "nomad-server-pool"

  health_checks = [
    google_compute_http_health_check.nomad.name,
  ]
}
