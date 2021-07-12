resource "google_compute_region_instance_group_manager" "nomad_server" {
  name = "nomad-server-group-manager"

  base_instance_name        = "nomad-server"
  region                    = var.project_region
  distribution_policy_zones = var.instance_zones

  version {
    instance_template = google_compute_instance_template.nomad_server.id
  }

  target_pools = [google_compute_target_pool.nomad_server.id]
  target_size  = var.nomad_server_instance_count

  named_port {
    name = "http"
    port = 4646
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.nomad.self_link
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    min_ready_sec                = 30
    replacement_method           = "SUBSTITUTE"
    max_surge_fixed              = 3

  }
}

resource "google_compute_instance_template" "nomad_server" {
  name_prefix  = "nomad-server-"
  machine_type = var.nomad_server_instance_type

  tags = [var.nomad_server_instance_tag, "allow-health-check"]

  disk {
    source_image = var.nomad_server_instance_image
    auto_delete  = true
    disk_size_gb = 20
    boot         = true
  }

  metadata_startup_script = templatefile("${path.module}/cloud-init/nomad_server.sh", {
    NOMAD_SERVER_COUNT = var.nomad_server_instance_count
    NOMAD_SERVER_TAG   = var.nomad_server_instance_tag
    CONSUL_SERVER_TAG  = var.consul_server_instance_tag
    CONSUL_TOKEN       = data.consul_acl_token_secret_id.nomad_server.secret_id
  })

  can_ip_forward = false
  network_interface {
    network = "default"

    access_config {}
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "cloud-platform"]
  }
}

resource "google_compute_target_pool" "nomad_server" {
  name = "nomad-server-pool"

  health_checks = [
    google_compute_http_health_check.nomad.name,
  ]
}

resource "consul_acl_policy" "nomad_server" {
  name  = "nomad-server"
  rules = <<-RULE
      agent_prefix "" {
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
    RULE

  depends_on = [
    google_compute_instance_template.consul_server,
    google_compute_region_backend_service.consul_server,
    google_compute_health_check.consul,
    google_compute_firewall.consul_allow_whitelist,
    google_compute_forwarding_rule.consul_server_internal,
    google_compute_region_instance_group_manager.consul_server,
    google_compute_target_pool.consul_server,
    google_dns_record_set.consul_bongo,
    google_dns_record_set.consul_server
  ]

}

resource "consul_acl_token" "nomad_server" {
  policies = [consul_acl_policy.nomad_server.name]
  local    = true

  depends_on = [
    google_compute_instance_template.consul_server,
    google_compute_region_backend_service.consul_server,
    google_compute_health_check.consul,
    google_compute_firewall.consul_allow_whitelist,
    google_compute_forwarding_rule.consul_server_internal,
    google_compute_region_instance_group_manager.consul_server,
    google_compute_target_pool.consul_server,
    google_dns_record_set.consul_bongo,
    google_dns_record_set.consul_server
  ]

}

data "consul_acl_token_secret_id" "nomad_server" {
  accessor_id = consul_acl_token.nomad_server.id
}