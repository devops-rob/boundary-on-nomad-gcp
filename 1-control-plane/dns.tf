data "google_dns_managed_zone" "internal" {
  name = "internal"
}

resource "google_dns_record_set" "consul_server" {
  managed_zone = data.google_dns_managed_zone.internal.name
  name         = "consul.${data.google_dns_managed_zone.internal.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_forwarding_rule.consul_server_internal.ip_address]
  ttl          = 300
}

resource "google_dns_record_set" "nomad_server" {
  managed_zone = data.google_dns_managed_zone.internal.name
  name         = "nomad.${data.google_dns_managed_zone.internal.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_forwarding_rule.nomad_server_internal.ip_address]
  ttl          = 300
}

data "google_dns_managed_zone" "bongo" {
  name = "bongo-codes"
}

resource "google_dns_record_set" "nomad_bongo" {
  managed_zone = data.google_dns_managed_zone.bongo.name
  name         = "nomad.${data.google_dns_managed_zone.bongo.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_global_address.ingress.address]
  ttl          = 300
}

resource "google_dns_record_set" "consul_bongo" {
  managed_zone = data.google_dns_managed_zone.bongo.name
  name         = "consul.${data.google_dns_managed_zone.bongo.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_global_address.ingress.address]
  ttl          = 300
}
