variable "project_id" {
  description = "GCP project name"
}

variable "project_region" {
  description = "GCP region, e.g. us-east1"
  default     = "europe-west1"
}

variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-a"
  default     = "europe-west1-b"
}

variable "database_instance_prefix" {
  type    = string
  default = "bong"
}

variable "database_instance_type" {
  type    = string
  default = "db-g1-small"
}

variable "database_instance_version" {
  type    = string
  default = "POSTGRES_13"
}

variable "database_names" {
  type    = list(string)
  default = ["boundary"]
}

variable "consul_master_token" {
  type = string
}

variable "nomad_token" {
    type = string
}