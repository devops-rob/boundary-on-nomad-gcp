build {
  sources = ["source.googlecompute.crypto_challenge"]

  provisioner "file" {
    source      = "./scripts"
    destination = "/tmp/scripts"
  }

  provisioner "shell" {
    script = "./scripts/setup.sh"

    environment_vars = [
      "NOMAD_ENABLED=true",
      "CONSUL_ENABLED=true"
    ]
  }
}