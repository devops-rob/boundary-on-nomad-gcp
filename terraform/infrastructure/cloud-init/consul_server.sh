#!/bin/bash
# Configure Consul.
mkdir -p /etc/consul.d
cat <<EOF > /etc/consul.d/server.hcl
log_level = "DEBUG"
data_dir = "/etc/consul.d/data"

datacenter = "dc1"

server = true

bootstrap_expect = ${CONSUL_SERVER_COUNT}
ui_config {
  enabled = true
}

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

# Set up ACLs.
cat <<EOF > /etc/consul.d/acl.hcl
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true

  tokens {
    master = "${CONSUL_MASTER_TOKEN}"
  }
}
EOF

systemctl restart consul