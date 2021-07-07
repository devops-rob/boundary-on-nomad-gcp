#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
echo "waiting 180 seconds for cloud-init to update /etc/apt/sources.list"
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'
 sudo apt-get update &&  sudo apt-get -y upgrade
 sudo apt-get -y install \
    git curl wget \
    apt-transport-https \
    ca-certificates \
    curl \
    sudo \
    jq \
    vim \
    nano \
    unzip \
    software-properties-common
curl -fsSL "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.0.0/docker-credential-gcr_linux_amd64-2.0.0.tar.gz" \
| tar xz --to-stdout ./docker-credential-gcr \
> /usr/bin/docker-credential-gcr && chmod +x /usr/bin/docker-credential-gcr
# Install Docker
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
sudo apt-get update && sudo apt-get install -y docker-ce
if [ "${NOMAD_ENABLED}" == "true" ]; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install nomad
#  curl -fsSL -o /tmp/nomad.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
#  unzip -o -d /usr/local/bin/ /tmp/nomad.zip
  mkdir -p /etc/nomad.d/
#  cp /tmp/files/nomad.service /etc/systemd/system/nomad.service
#  systemctl daemon-reload
#  systemctl enable nomad.service
fi
#if [ "${CONSUL_ENABLED}" == "true" ]; then
#  curl -fsSL -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
#  unzip -o -d /usr/local/bin/ /tmp/consul.zip
#  mkdir -p /etc/consul.d/
#  cp /tmp/files/consul.service /etc/systemd/system/consul.service
#  systemctl daemon-reload
#  systemctl enable consul.service
#fi
#if [ "${VAULT_ENABLED}" == "true" ]; then
#  curl -fsSL -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
#  unzip -o -d /usr/local/bin/ /tmp/vault.zip
#  mkdir -p /etc/vault.d/
#  cp /tmp/files/vault.service /etc/systemd/system/vault.service
#  systemctl daemon-reload
#  systemctl enable vault.service
#fi