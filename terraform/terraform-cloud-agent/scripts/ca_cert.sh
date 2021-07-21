#!/bin/bash

mkdir -p /certs

echo ${CA_CERT} |  sed 's/[][]//g' |\
 sed 's/<<-EOT//g' | \
 sed 's/EOT,//g' | \
 sed '/^[[:space:]]*$/d' > ca.crt