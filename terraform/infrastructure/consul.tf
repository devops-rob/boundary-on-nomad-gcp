//resource "consul_acl_auth_method" "jwt" {
//  name = "jwt"
//  type = "jwt"
//
//  config_json = jsonencode({
//    BoundAudiences   = ["consul"]
//    JWKSURL          = "https://www.googleapis.com/oauth2/v3/certs"
//    JWTSupportedAlgs = "RS256"
//    BoundIssuer      = "https://accounts.google.com"
//    ClaimMappings = {
//      id = "google/compute_engine/instance_name"
//    }
//  })
//}
//
//resource "consul_acl_policy" "node" {
//  name  = "node"
//  rules = <<-RULE
//    node_prefix "nomad-client-" {
//      policy = "write"
//    }
//
//    agent_prefix "nomad-client-" {
//      policy = "write"
//    }
//
//    node_prefix "nomad-server-" {
//      policy = "write"
//    }
//
//    agent_prefix "nomad-server-" {
//      policy = "write"
//    }
//
//    key_prefix "_rexec" {
//      policy = "write"
//    }
//
//    node_prefix "" {
//      policy = "read"
//    }
//
//    agent_prefix "" {
//      policy = "read"
//    }
//    RULE
//}
//
//resource "consul_acl_role" "node" {
//  name = "node"
//  policies = [
//    consul_acl_policy.node.id
//  ]
//}
//
//resource "consul_acl_binding_rule" "node_binding" {
//  auth_method = consul_acl_auth_method.jwt.name
//  bind_type   = "role"
//  bind_name   = "node"
//}
