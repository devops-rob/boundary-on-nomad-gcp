#!/bin/bash

mkdir -p /var/certs

echo "WRITING CERTIFICATE FILE"

cat <<EOF > ${ca_path}
${ca_cert}
EOF

echo "DONE"

cat ${ca_path}