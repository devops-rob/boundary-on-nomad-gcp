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
sudo curl -fsSL "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.0.0/docker-credential-gcr_linux_amd64-2.0.0.tar.gz" \
| sudo tar xz --to-stdout ./docker-credential-gcr \
> docker-credential-gcr && sudo mv docker-credential-gcr /usr/bin && sudo chmod +x /usr/bin/docker-credential-gcr

# Install Docker
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
sudo apt-get update && sudo apt-get install -y docker-ce
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
if [ "${NOMAD_ENABLED}" == "true" ]; then
  sudo apt-get install nomad
  mkdir -p /etc/nomad.d/
fi
if [ "${CONSUL_ENABLED}" == "true" ]; then
  sudo apt-get install consul
  mkdir -p /etc/consul.d/
fi
if [ "${VAULT_ENABLED}" == "true" ]; then
  sudo apt-get install vault
  mkdir -p /etc/vault.d/
fi