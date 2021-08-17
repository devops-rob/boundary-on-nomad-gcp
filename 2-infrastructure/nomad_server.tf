
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
    google_dns_record_set.consul_server,
    null_resource.consul_race_condition
  ]

}

resource "consul_acl_token" "nomad_server" {
  policies = [consul_acl_policy.nomad_server.name]
  local    = true
  id = random_id.database.id


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

data "consul_acl_token_secret_id" "nomad_server" {
  accessor_id = consul_acl_token.nomad_server.id
}