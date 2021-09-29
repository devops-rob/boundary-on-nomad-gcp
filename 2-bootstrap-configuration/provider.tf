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

data "google_compute_forwarding_rule" "nomad" {
    name = "nomad-server-internal-forwarding-rule"
}

data "google_compute_forwarding_rule" "consul" {
    name = "consul-server-internal-forwarding-rule"
}

provider "nomad" {
  address      = "http://${data.google_compute_forwarding_rule.nomad.ip_address}:4646"
  secret_id    = data.consul_acl_token_secret_id.nomad_server.secret_id
  consul_token = var.consul_master_token
}

provider "consul" {
  address = "http://${data.google_compute_forwarding_rule.consul.ip_address}:8500"
  token   = var.consul_master_token
}
