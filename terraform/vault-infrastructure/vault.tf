module "vault" {
  source         = "terraform-google-modules/vault/google"
  project_id     = var.project_id
  region         = var.project_region
  kms_keyring    = "hashicorp-vault"
  kms_crypto_key = "vault-init"
}

output "vault_addr" {
  value = module.vault.vault_addr
}