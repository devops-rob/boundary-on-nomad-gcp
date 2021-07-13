resource "google_compute_region_instance_group_manager" "boundary_controller" {
  name = "boundary-controller-group-manager"

  base_instance_name        = "boundary-controller"
  region                    = var.project_region
  distribution_policy_zones = var.instance_zones

  version {
    instance_template = google_compute_instance_template.boundary_controller.id
  }

  target_pools = [google_compute_target_pool.boundary_controller.id]
  target_size  = var.boundary_controller_instance_count

  named_port {
    name = "nomad"
    port = 4646
  }

  named_port {
    name = "https"
    port = 443
  }

  named_port {
    name = "http"
    port = 80
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

resource "google_compute_instance_template" "boundary_controller" {
  name_prefix  = "boundary-controller-"
  machine_type = var.nomad_client_instance_type

  tags = [var.nomad_client_instance_tag, "allow-health-check", "allow-http"]

  disk {
    source_image = var.nomad_client_instance_image
    auto_delete  = true
    disk_size_gb = 20
    boot         = true
  }

  metadata_startup_script = templatefile("${path.module}/cloud-init/nomad_client.sh", {
    NOMAD_SERVER_TAG  = var.nomad_server_instance_tag
    CONSUL_SERVER_TAG = var.consul_server_instance_tag
    CONSUL_TOKEN      = data.consul_acl_token_secret_id.boundary_controller.secret_id
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

resource "google_compute_target_pool" "boundary_controller" {
  name = "boundary-controller-pool"

  health_checks = [
    google_compute_http_health_check.nomad.name,
  ]
}

resource "consul_acl_policy" "boundary_controller" {
  name  = "boundary-controller"
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

resource "consul_acl_token" "boundary_controller" {
  policies = [consul_acl_policy.boundary_controller.name]
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

data "consul_acl_token_secret_id" "boundary_controller" {
  accessor_id = consul_acl_token.boundary_controller.id
}