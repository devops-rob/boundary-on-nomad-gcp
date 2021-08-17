module "nomad_tls_cert" {
  source = "devops-rob/tls/gcp"
  version = "0.1.4"

  project_id            = var.project_id
  region                = var.project_region
  service_account_email = google_compute_instance_template.nomad_server.service_account.email
  tls_bucket            = "nomad-tls"
  tls_cert_name         = "nomad"
}

module "consul_tls_cert" {
  source = "devops-rob/tls/gcp"
  version = "0.1.4"

  project_id            = var.project_id
  region                = var.project_region
  service_account_email = google_compute_instance_template.consul_server.service_account.email
  tls_bucket            = "consul-tls"
  tls_cert_name         = "consul"
}

module "boundary_tls_cert" {
  source = "devops-rob/tls/gcp"
  version = "0.1.4"

  project_id            = var.project_id
  region                = var.project_region
  service_account_email = google_compute_instance_template.boundary_controller.service_account.email
  tls_bucket            = "boundary-tls"
  tls_cert_name         = "boundary"
}