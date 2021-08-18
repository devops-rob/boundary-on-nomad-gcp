resource "random_id" "kms" {
  byte_length = 8
}

module "vault" {
  source = "terraform-google-modules/vault/google"

  version        = "v6.0.0"
  project_id     = var.project_id
  region         = var.project_region
  kms_keyring    = "hashicorp-vault-${random_id.kms.hex}"
  kms_crypto_key = var.vault_kms_crypto_key
  allow_ssh      = false

  vault_ca_cert_filename  = var.vault_ca_cert_filename
  vault_tls_cert_filename = var.vault_tls_cert_filename
  vault_tls_key_filename  = var.vault_tls_key_filename

  vault_allowed_cidrs = var.allow_list

//  network = data.google_compute_network.default.self_link
//  subnet  = data.google_compute_subnetwork.default.self_link
}

output "vault_addr" {
  value = module.vault.vault_addr
}

output "vault_ca_cert" {
  value     = module.vault.ca_cert_pem[0]
  sensitive = true
}

data "google_kms_key_ring" "vault" {
  name     = "hashicorp-vault-${random_id.kms.hex}"
  location = var.project_region
}
data "google_kms_crypto_key" "vault" {
  name     = var.vault_kms_crypto_key
  key_ring = data.google_kms_key_ring.vault.self_link
}

data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = var.project_region
}