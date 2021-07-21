resource "vault_token_auth_backend_role" "nomad" {
  role_name              = "nomad"
  allowed_policies       = ["boundary"]
  disallowed_policies    = ["nomad"]
  orphan                 = true
  token_period           = "259200"
  renewable              = true
  token_explicit_max_ttl = "0"
  path_suffix            = "nomad-role"
}