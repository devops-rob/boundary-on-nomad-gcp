terraform {
  required_version = ">= 0.12.31"
  required_providers {
    google = {
      version = "~> 3.69"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

data "google_project" "project" {}
