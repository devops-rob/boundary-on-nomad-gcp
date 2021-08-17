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

# Download TLS files from GCS
mkdir -p /etc/nomad.d/tls
gsutil cp "gs://${nomad_tls_bucket}/${nomad_ca_cert_filename}" /etc/nomad.d/tls/nomad-ca.crt
gsutil cp "gs://${nomad_tls_bucket}/${nomad_tls_cert_filename}" /etc/nomad.d/tls/nomad.crt
gsutil cp "gs://${nomad_tls_bucket}/${nomad_tls_key_filename}" /etc/nomad.d/tls/nomad.key.enc

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

acl {
  enabled = true
}
EOF

# cat <<EOF > /etc/nomad.d/acl.hcl
# acl = {
#   enabled = true
# }
# EOF

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
