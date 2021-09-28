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
}

resource "consul_acl_role" "node" {
  name = "node"
  policies = [
    consul_acl_policy.node.id
  ]
}

resource "consul_acl_binding_rule" "node_binding" {
  auth_method = consul_acl_auth_method.jwt.name
  bind_type   = "role"
  bind_name   = "node"
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
}

resource "consul_acl_token" "nomad_server" {
  policies = [consul_acl_policy.nomad_server.name]
  local    = true
}

data "consul_acl_token_secret_id" "nomad_server" {
  accessor_id = consul_acl_token.nomad_server.id
}