#!/bin/bash

mkdir -p /etc/consul.d

# Configure Consul.
mkdir -p /etc/consul.d
cat <<EOF > /etc/consul.d/consul.hcl
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

# verify_incoming = true,
# verify_outgoing = true,
# verify_server_hostname = true,
# ca_file = "/etc/consul.d/tls/consul-ca.crt",
# cert_file = "/etc/consul.d/tls/consul.crt",
# key_file = "/etc/consul.d/tls/consul.key",
# auto_encrypt {
#   allow_tls = true
# }

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

# configure Consul for Nomad authentication

# export CONSUL_CACERT=/etc/consul.d/tls/consul-ca.crt
# export CONSUL_CLIENT_CERT=/etc/consul.d/tls/consul.crt
# export CONSUL_CLIENT_KEY=/etc/consul.d/tls/consul.key
export CONSUL_HTTP_ADDR=https://127.0.0.1:8500
export CONSUL_HTTP_TOKEN="${CONSUL_MASTER_TOKEN}"

consul acl auth-method create \
  -name=jwt -type=jwt \
  -config=\
  '
    BoundAudiences   = ["consul"]
    JWKSURL          = "https://www.googleapis.com/oauth2/v3/certs"
    JWTSupportedAlgs = "RS256"
    BoundIssuer      = "https://accounts.google.com"
    ClaimMappings = {
      id = "google/compute_engine/instance_name"
    }
  }'

consul acl policy create \
  -name=node -rules=\
  '    node_prefix "nomad-client-" {
         policy = "write"
       }

       agent_prefix "nomad-client-" {
         policy = "write"
       }

       node_prefix "nomad-server-" {
         policy = "write"
       }

       agent_prefix "nomad-server-" {
         policy = "write"
       }

       key_prefix "_rexec" {
         policy = "write"
       }

       node_prefix "" {
         policy = "read"
       }

       agent_prefix "" {
         policy = "read"
       }
'

consul acl role create \
  -name=node \
  -policy-name=node

consul acl binding-rule create \
  -bind-name=node \
  -bind-type=role \
  -method=jwt

consul acl policy create \
  -name=nomad-server \
  -rules=\
'      agent_prefix "" {
        policy = "read"
      }

      node_prefix "" {
        policy = "read"
      }

      service_prefix "" {
        policy = "write"
      }

      acl = "write"
      operator = "write"
'

consul token create \
  -secret="${CONSUL_TOKEN_NOMAD_SERVER}" \
  -policy-name=nomad-server

consul acl policy create \
  -name=boundary-controller \
  -rules=\
'      agent_prefix "" {
         policy = "read"
       }

       node_prefix "" {
         policy = "read"
       }

       service_prefix "" {
         policy = "write"
       }
'
consul token create \
  -secret="${CONSUL_TOKEN_BOUNDARY_CONTROLLER}" \
  -policy-name=boundary-controller
