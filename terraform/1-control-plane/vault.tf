//module "vault" {
//  source         = "terraform-google-modules/vault/google"
//  project_id     = var.project_id
//  region         = var.project_region
//  kms_keyring    = "hashicorp-vault"
//  kms_crypto_key = "vault-init"
//  allow_ssh      = false
//
//  vault_allowed_cidrs = var.allow_list
//}
//
//output "vault_addr" {
//  value = module.vault.vault_addr
//}
//
//output "vault_ca_cert" {
//  value     = module.vault.ca_cert_pem[0]
//  sensitive = true
//}