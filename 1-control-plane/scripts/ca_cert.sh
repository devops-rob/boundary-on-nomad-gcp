#!/bin/bash

mkdir -p /var/certs
#
#echo "WRITING VAULT CERTIFICATE FILE"
#
#cat <<EOF > ${ca_path}
#${ca_cert}
#EOF
#
#echo "DONE"
#
#cat ${ca_path}


# Download Nomad TLS files from GCS
mkdir -p /etc/nomad.d/tls
gsutil cp "gs://${nomad_tls_bucket}/${nomad_ca_cert_filename}" /var/certs/nomad-ca.crt
gsutil cp "gs://${nomad_tls_bucket}/${nomad_tls_cert_filename}" /var/certs/nomad.crt
gsutil cp "gs://${nomad_tls_bucket}/${nomad_tls_key_filename}" /var/certs/nomad.key.enc

base64 --decode < /var/certs/nomad.key.enc | gcloud kms decrypt \
  --project="${kms_project}" \
  --key="${nomad_kms_crypto_key}" \
  --plaintext-file=/var/certs/nomad.key \
  --ciphertext-file=-

cp /var/certs/nomad-ca.crt /usr/local/share/ca-certificates/

# Vault TLS certificates

mkdir -p /etc/nomad.d/tls
gsutil cp "gs://${vault_tls_bucket}/${vault_ca_cert_filename}" /var/certs/vault-ca.crt
gsutil cp "gs://${vault_tls_bucket}/${vault_tls_cert_filename}" /var/certs/vault.crt
gsutil cp "gs://${vault_tls_bucket}/${vault_tls_key_filename}" /var/certs/vault.key.enc

base64 --decode < /var/certs/vault.key.enc | gcloud kms decrypt \
  --project="${kms_project}" \
  --key="${vault_kms_crypto_key}" \
  --plaintext-file=/var/certs/vault.key \
  --ciphertext-file=-

cp /var/certs/vault-ca.crt /usr/local/share/ca-certificates/

# Consul TLS certificates

mkdir -p /etc/consul.d/tls
gsutil cp "gs://${consul_tls_bucket}/${consul_ca_cert_filename}" /var/certs/consul-ca.crt
gsutil cp "gs://${consul_tls_bucket}/${consul_tls_cert_filename}" /var/certs/consul.crt
gsutil cp "gs://${consul_tls_bucket}/${consul_tls_key_filename}" /var/certs/consul.key.enc

base64 --decode < /etc/consul.d/tls/consul.key.enc | gcloud kms decrypt \
  --project="${kms_project}" \
  --key="${consul_kms_crypto_key}" \
  --plaintext-file=/var/certs/consul.key \
  --ciphertext-file=-

cp /var/certs/consul-ca.crt /usr/local/share/ca-certificates/
update-ca-certificates
