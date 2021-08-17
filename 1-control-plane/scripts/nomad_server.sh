#!/bin/bash
# Set up credential helpers for Google Container Registry.
mkdir -p /etc/docker
cat <<EOF > /etc/docker/config.json
{
  "credHelpers": {
    "gcr.io": "gcr"
  }
}
EOF

# Install the CNI Plugins
curl -L https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz -o /tmp/cni.tgz
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf /tmp/cni.tgz

# Create Nomad directory.
mkdir -p /etc/nomad.d

# Download Nomad TLS files from GCS
mkdir -p /etc/nomad.d/tls
gsutil cp "gs://${nomad_tls_bucket}/${nomad_ca_cert_filename}" /etc/nomad.d/tls/nomad-ca.crt
gsutil cp "gs://${nomad_tls_bucket}/${nomad_tls_cert_filename}" /etc/nomad.d/tls/nomad.crt
gsutil cp "gs://${nomad_tls_bucket}/${nomad_tls_key_filename}" /etc/nomad.d/tls/nomad.key.enc

base64 --decode < /etc/nomad.d/tls/nomad.key.enc | gcloud kms decrypt \
  --project="${kms_project}" \
  --key="${nomad_kms_crypto_key}" \
  --plaintext-file=/etc/vault.d/tls/nomad.key \
  --ciphertext-file=-

cp /etc/nomad.d/tls/nomad-ca.crt /usr/local/share/ca-certificates/

# Vault TLS certificates

mkdir -p /etc/nomad.d/tls
gsutil cp "gs://${vault_tls_bucket}/${vault_ca_cert_filename}" /etc/vault.d/tls/vault-ca.crt
gsutil cp "gs://${vault_tls_bucket}/${vault_tls_cert_filename}" /etc/vault.d/tls/vault.crt
gsutil cp "gs://${vault_tls_bucket}/${vault_tls_key_filename}" /etc/vault.d/tls/vault.key.enc

base64 --decode < /etc/vault.d/tls/vault.key.enc | gcloud kms decrypt \
  --project="${kms_project}" \
  --key="${vault_kms_crypto_key}" \
  --plaintext-file=/etc/vault.d/tls/vault.key \
  --ciphertext-file=-

cp /etc/vault.d/tls/vault-ca.crt /usr/local/share/ca-certificates/

# Consul TLS certificates

mkdir -p /etc/consul.d/tls
gsutil cp "gs://${consul_tls_bucket}/${consul_ca_cert_filename}" /etc/consul.d/tls/consul-ca.crt
gsutil cp "gs://${consul_tls_bucket}/${consul_tls_cert_filename}" /etc/consul.d/tls/consul.crt
gsutil cp "gs://${consul_tls_bucket}/${consul_tls_key_filename}" /etc/consul.d/tls/consul.key.enc

base64 --decode < /etc/consul.d/tls/consul.key.enc | gcloud kms decrypt \
  --project="${kms_project}" \
  --key="${consul_kms_crypto_key}" \
  --plaintext-file=/etc/consul.d/tls/consul.key \
  --ciphertext-file=-

cp /etc/consul.d/tls/consul-ca.crt /usr/local/share/ca-certificates/
update-ca-certificates


# Nomad configuration files
cat <<EOF > /etc/nomad.d/nomad.hcl
log_level = "DEBUG"
data_dir = "/etc/nomad.d/data"

server {
  enabled = true
  bootstrap_expect = ${NOMAD_SERVER_COUNT}
  server_join {
    retry_join = ["provider=gce tag_value=${NOMAD_SERVER_TAG}"]
  }
}

tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad.d/tls/nomad-ca.crt"
  cert_file = "/etc/nomad.d/tls/nomad.crt"
  key_file  = "/etc/nomad.d/tls/nomad.key.enc"

  verify_server_hostname = true
  verify_https_client    = true
}

autopilot {
    cleanup_dead_servers      = true
    last_contact_threshold    = "200ms"
    max_trailing_logs         = 250
    server_stabilization_time = "10s"
    enable_redundancy_zones   = false
    disable_upgrade_migration = false
    enable_custom_upgrades    = false
}

consul {
  address = "localhost:8500"

  server_service_name = "nomad"
  client_service_name = "nomad-client"

  auto_advertise = true

  server_auto_join = true
  client_auto_join = true

  token = "${CONSUL_TOKEN}"
}

vault {
  enabled     = true
  ca_file     = "/etc/vault.d/tls/vault-ca.crt"
  cert_file   = "/etc/vault.d/tls/vault.crt"
  key_file    = "/etc/vault.d/tls/nomad.key"

  address     = "${VAULT_ADDR}"

  token       = "${VAULT_TOKEN}"

  create_from_role = "nomad-cluster"
}

EOF

 cat <<EOF > /etc/nomad.d/acl.hcl
 acl = {
   enabled = true
 }
EOF

systemctl restart nomad

# Configure Consul.
mkdir -p /etc/consul.d
cat <<EOF > /etc/consul.d/client.hcl
log_level = "DEBUG"
data_dir = "/etc/consul.d/data"

datacenter = "dc1"

bind_addr = "{{ GetInterfaceIP \"ens4\" }}"
client_addr = "0.0.0.0"

retry_join = ["provider=gce tag_value=${CONSUL_SERVER_TAG}"]

ports {
  grpc = 8502
}

connect {
  enabled = true
}
EOF

cat <<EOF > /etc/consul.d/acl.hcl
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
EOF

curl -s -H "Metadata-Flavor: Google" "http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience=consul&format=full" > bearer.token
consul login -method=jwt -bearer-token-file=bearer.token -token-sink-file=agent.token
CONSUL_HTTP_TOKEN=$(cat agent.token)
consul acl set-agent-token default $CONSUL_HTTP_TOKEN

systemctl restart consul
