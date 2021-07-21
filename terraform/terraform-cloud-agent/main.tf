resource "google_service_account" "tfc-agent" {
  project      = var.gcp_project
  display_name = "tfc-agent Service Account"
  account_id   = "tfc-agent"
}

# a role for terraform consumer to impersonate
# you'll need to customize IAM bindings to access resources as desired
resource "google_service_account" "terraform-dev-role" {
  project      = var.gcp_project
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
  project = var.gcp_project
  role    = "roles/compute.admin"
  members = [
    "serviceAccount:${google_service_account.terraform-dev-role.email}",
  ]
}

data "terraform_remote_state" "vault_infrastructure" {
  backend = "remote"
  config = {
    organization = var.org
    workspaces = {
      name = "boundary-on-nomad-gcp-vault-infra"
    }
  }
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

//  metadata_startup_script = templatefile("${path.module}/scripts/ca_cert.sh", {
//    CA_CERT = data.terraform_remote_state.vault_infrastructure.outputs.vault_ca_cert
//  })

  metadata = {
    google-logging-enabled    = "true"
    gce-container-declaration = <<EOT
spec:
  containers:
    - image: docker.io/hashicorp/tfc-agent:latest
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
      volumeMounts: ['type=volume,src=/certs,dst=local/certs']
      restartPolicy: Always
      volumes: []

EOT
  }

  network_interface {
    network = "default"

    access_config {}
  }

  service_account {
    email  = google_service_account.tfc-agent.email
    scopes = ["cloud-platform", "userinfo-email"]
  }
}