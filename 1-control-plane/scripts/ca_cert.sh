#!/bin/bash

mkdir -p /var/certs/vault

echo "WRITING VAULT CERTIFICATE FILE"

cat <<EOF > ${ca_path}
${ca_cert}
EOF

echo "DONE"

cat ${ca_path}