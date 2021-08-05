terraform {
  required_version = ">= 0.12.31"
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
