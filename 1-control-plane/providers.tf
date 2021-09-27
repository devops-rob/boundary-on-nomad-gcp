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

provider "nomad" {
  address      = "http://${google_compute_forwarding_rule.nomad_server_internal.ip_address}:4646"
  secret_id    = data.consul_acl_token_secret_id.nomad_server.secret_id
  consul_token = var.consul_master_token
}
