locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "googlecompute" "crypto_challenge" {
  project_id   = var.project_id
  source_image = var.source_image
  ssh_username = var.ssh_username
  communicator = "ssh"
  zone         = var.zone

  account_file = var.account_file
  image_name   = "${var.hashicorp_tool}-${local.timestamp}"
}

