//noinspection MissingProperty
resource "consul_acl_auth_method" "jwt" {
  name = "jwt"
  type = "jwt"

  config_json = jsonencode({
    BoundAudiences   = ["consul"]
    JWKSURL          = "https://www.googleapis.com/oauth2/v3/certs"
    JWTSupportedAlgs = "RS256"
    BoundIssuer      = "https://accounts.google.com"
    ClaimMappings = {
      id = "google/compute_engine/instance_name"
    }
  })

  depends_on = [
    google_compute_instance_template.consul_server,
    google_compute_region_backend_service.consul_server,
    google_compute_health_check.consul,
    google_compute_firewall.consul_allow_whitelist,
    google_compute_forwarding_rule.consul_server_internal,
    google_compute_region_instance_group_manager.consul_server,
    google_compute_target_pool.consul_server,
    google_dns_record_set.consul_bongo,
    google_dns_record_set.consul_server,
    null_resource.consul_race_condition
  ]
}

resource "consul_acl_policy" "node" {
  name  = "node"
  rules = <<-RULE
    node_prefix "nomad-client-" {
      policy = "write"
    }

    agent_prefix "nomad-client-" {
      policy = "write"
    }

    node_prefix "nomad-server-" {
      policy = "write"
    }

    agent_prefix "nomad-server-" {
      policy = "write"
    }

    key_prefix "_rexec" {
      policy = "write"
    }

    node_prefix "" {
      policy = "read"
    }

    agent_prefix "" {
      policy = "read"
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
    google_dns_record_set.consul_server,
    null_resource.consul_race_condition
  ]

}

resource "consul_acl_role" "node" {
  name = "node"
  policies = [
    consul_acl_policy.node.id
  ]

  depends_on = [
    google_compute_instance_template.consul_server,
    google_compute_region_backend_service.consul_server,
    google_compute_health_check.consul,
    google_compute_firewall.consul_allow_whitelist,
    google_compute_forwarding_rule.consul_server_internal,
    google_compute_region_instance_group_manager.consul_server,
    google_compute_target_pool.consul_server,
    google_dns_record_set.consul_bongo,
    google_dns_record_set.consul_server,
    null_resource.consul_race_condition
  ]

}

resource "consul_acl_binding_rule" "node_binding" {
  auth_method = consul_acl_auth_method.jwt.name
  bind_type   = "role"
  bind_name   = "node"

  depends_on = [
    google_compute_instance_template.consul_server,
    google_compute_region_backend_service.consul_server,
    google_compute_health_check.consul,
    google_compute_firewall.consul_allow_whitelist,
    google_compute_forwarding_rule.consul_server_internal,
    google_compute_region_instance_group_manager.consul_server,
    google_compute_target_pool.consul_server,
    google_dns_record_set.consul_bongo,
    google_dns_record_set.consul_server,
    null_resource.consul_race_condition
  ]

}

resource "consul_config_entry" "service_intentions" {
  name = "cloudsql"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "boundary"
        Type       = "consul"
      },
    ]
  })
}

resource "null_resource" "consul_race_condition" {

  provisioner "local-exec" {

    command = "sleep 180"

  }

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