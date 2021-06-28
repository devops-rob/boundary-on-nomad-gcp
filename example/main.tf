terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.60.0"
    }

    nomad = {
      source  = "hashicorp/nomad"
      version = "1.4.15"
    }

    consul = {
      source  = "hashicorp/consul"
      version = "2.12.0"
    }
  }
}

provider "nomad" {
  address      = "http://${google_compute_forwarding_rule.nomad_server_internal.ip_address}:4646"
  secret_id    = data.consul_acl_token_secret_id.nomad_server.secret_id
  consul_token = var.consul_master_token
}

provider "consul" {
  address = "http://${google_compute_forwarding_rule.consul_server_internal.ip_address}:8500"
  token   = var.consul_master_token
}

provider "google" {
  project = var.project_id
  region  = var.project_region
}

data "google_project" "project" {}