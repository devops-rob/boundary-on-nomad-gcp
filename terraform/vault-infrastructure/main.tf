terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.60.0"
    }

  }
}

provider "google" {
  project = var.project_id
  region  = var.project_region
}

data "google_project" "project" {}