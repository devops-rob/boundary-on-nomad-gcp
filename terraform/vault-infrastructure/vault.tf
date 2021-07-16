module "vault_example_vault-on-gce" {
  source  = "terraform-google-modules/vault/google//examples/vault-on-gce"
  version = "5.3.0"

  project_id = var.project_id
  kms_location = var.kms_location
  region = var.project_region

}