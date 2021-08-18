resource "google_service_account" "tfc-agent" {
  project      = var.project_id
  display_name = "tfc-agent Service Account"
  account_id   = "tfc-agent"
}

# a role for terraform consumer to impersonate
# you'll need to customize IAM bindings to access resources as desired
resource "google_service_account" "terraform-dev-role" {
  project      = var.project_id
  display_name = "terraform-dev-role Service Account"
  account_id   = "terraform-dev-role"
}

resource "google_service_account_iam_binding" "terraform-dev-role" {
  service_account_id = google_service_account.terraform-dev-role.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${google_service_account.tfc-agent.email}",
  ]
}

resource "google_project_iam_binding" "compute-admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  members = [
    "serviceAccount:${google_service_account.terraform-dev-role.email}",
  ]
}

locals {
  //  ca_cert = join("\",\"", module.vault.ca_cert_pem[0])
  ca_path = "/var/certs"
}

resource "google_compute_instance" "tfc-agent" {
  count        = 1
  name         = "${var.prefix}-${count.index}"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable-89-16108-403-26"
    }
  }

  labels = {
    container-vm = "cos-stable-89-16108-403-26"
  }

  metadata = {
    gce-container-declaration = <<EOT
spec:
  containers:
    - image: docker.io/hashicorp/tfc-agent:latest
      volumeMounts:
        - mountPath: ${local.ca_path}
          name: cert
          readOnly: true
      name: ${var.prefix}-${count.index}
      securityContext:
        privileged: false
      env:
        - name: TFC_AGENT_TOKEN
          value: ${var.tfc_agent_token}
        - name: TFC_AGENT_SINGLE
          value: true
      stdin: false
      tty: false
      restartPolicy: Always
  volumes:
    - hostPath:
        path: ${local.ca_path}
      name: cert
EOT
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/ca_cert.sh", {
    consul_tls_bucket        = module.consul_tls_cert.bucket_id
    consul_ca_cert_filename  = module.consul_tls_cert.ca_filename
    consul_tls_cert_filename = module.consul_tls_cert.cert_filename
    consul_tls_key_filename  = module.consul_tls_cert.key_filename
    consul_kms_crypto_key    = module.consul_tls_cert.key_id

    nomad_tls_bucket        = module.nomad_tls_cert.bucket_id
    nomad_ca_cert_filename  = module.nomad_tls_cert.ca_filename
    nomad_tls_cert_filename = module.nomad_tls_cert.cert_filename
    nomad_tls_key_filename  = module.nomad_tls_cert.key_filename
    nomad_kms_crypto_key    = module.nomad_tls_cert.key_id

    vault_ca_cert_filename  = var.vault_ca_cert_filename
    vault_tls_cert_filename = var.vault_tls_cert_filename
    vault_tls_key_filename  = var.vault_tls_key_filename
    vault_tls_bucket        = module.vault.vault_storage_bucket
    vault_kms_crypto_key    = var.vault_kms_crypto_key

    kms_project = var.project_id

  })

  network_interface {
    network = "default"

    access_config {}
  }

  service_account {
    email  = google_service_account.tfc-agent.email
    scopes = ["cloud-platform", "userinfo-email"]
  }
}