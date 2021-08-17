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
}

output "vault_addr" {
  value = module.vault.vault_addr
}

output "vault_ca_cert" {
  value     = module.vault.ca_cert_pem[0]
  sensitive = true
}