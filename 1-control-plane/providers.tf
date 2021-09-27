terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      version = "~> 3.69"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.project_region
}

data "google_project" "project" {}

provider "random" {}

# provider "nomad" {
#   address      = "http://${google_compute_instance_template.nomad_server.network_interface.0.access_config.0.nat_ip}:4646"
#   secret_id    = data.consul_acl_token_secret_id.nomad_server.secret_id
#   consul_token = var.consul_master_token
# }

# provider "consul" {
#   address = "http://${google_compute_instance_template.consul_server.network_interface.0.access_config.0.nat_ip}:8500"
#   token   = var.consul_master_token
# }
