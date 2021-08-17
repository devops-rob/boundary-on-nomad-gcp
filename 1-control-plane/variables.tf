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

variable "vault_kms_crypto_key" {
  type        = string
  default     = "vault-init"
  description = "Name of cryptographic KMS key used to encrypt/decrypt Vault's private key."
}

variable "vault_tls_cert_filename" {
  type    = string
  default = "vault.crt"

  description = "GCS object path within the vault_tls_bucket. This is the vault server certificate."

}

variable "vault_ca_cert_filename" {
  type    = string
  default = "vault-ca.crt"

  description = "GCS object path within the vault_tls_bucket. This is the root CA certificate."
}

variable "vault_tls_key_filename" {
  type    = string
  default = "vault.key.enc"

  description = "Encrypted and base64 encoded GCS object path within the vault_tls_bucket. This is the Vault TLS private key."
}
variable "allow_list" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List if IP addresses to allow access to Vault."
}


####


# Consul
variable "consul_server_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "consul_server_instance_count" {
  type    = number
  default = 3
}

variable "consul_server_instance_image" {
  type = string
}

variable "consul_server_instance_tag" {
  type    = string
  default = "consul-server"
}

# Nomad
variable "nomad_server_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "nomad_server_instance_count" {
  type    = number
  default = 3
}

variable "nomad_server_instance_image" {
  type = string
}

variable "nomad_server_instance_tag" {
  type    = string
  default = "nomad-server"
}

variable "nomad_client_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "boundary_controller_instance_count" {
  type    = number
  default = 3
}

variable "nomad_client_instance_image" {
  type = string
}

variable "nomad_client_instance_tag" {
  type    = string
  default = "nomad-client"
}

variable "whitelist" {
  type    = list(string)
  default = []
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