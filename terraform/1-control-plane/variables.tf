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

variable "machine_type" {
  description = "GCP machine type"
  default     = "g1-small"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
  default     = "tfc-agent"
}

variable "tfc_agent_token" {
  description = "Terraform Cloud agent token. (mark as sensitive) (TFC Organization Settings >> Agents)"
  sensitive   = true
}

variable "org" {
  type        = string
  description = "The TFC organisation."
}

variable "instance_zones" {
  type    = list(string)
  default = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}

variable "vault_server_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "vault_server_instance_count" {
  type    = number
  default = 3
}

variable "vault_server_instance_image" {
  type = string
}

variable "vault_server_instance_tag" {
  type    = string
  default = "vault-server"
}

variable "allow_list" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List if IP addresses to allow access to Vault."
}
