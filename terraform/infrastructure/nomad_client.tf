resource "google_compute_region_instance_group_manager" "nomad_client" {
  name = "nomad-client-group-manager"

  base_instance_name        = "nomad-client"
  region                    = var.project_region
  distribution_policy_zones = var.instance_zones

  version {
    instance_template = google_compute_instance_template.nomad_client.id
  }

  target_pools = [google_compute_target_pool.nomad_client.id]
  target_size  = var.nomad_client_instance_count

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
    max_unavailable_fixed        = 1
  }
}

resource "google_compute_instance_template" "nomad_client" {
  name_prefix  = "nomad-client-"
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
    CONSUL_TOKEN      = data.consul_acl_token_secret_id.nomad_client.secret_id
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

resource "google_compute_target_pool" "nomad_client" {
  name = "nomad-client-pool"

  health_checks = [
    google_compute_http_health_check.nomad.name,
  ]
}

resource "consul_acl_policy" "nomad_client" {
  name  = "nomad-client"
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
  ]
}

resource "consul_acl_token" "nomad_client" {
  policies = [consul_acl_policy.nomad_client.name]
  local    = true
}

data "consul_acl_token_secret_id" "nomad_client" {
  accessor_id = consul_acl_token.nomad_client.id
}