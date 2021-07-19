# Test for TFC

resource "vault_policy" "boundary" {
  name = "boundary"
  policy = <<EOF
path "secret/my_app" {
  capabilities = ["update"]
}
EOF
}