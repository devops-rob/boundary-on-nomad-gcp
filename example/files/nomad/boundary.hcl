job "boundary" {
  datacenters = ["dc1"]
  
  group "controller" {
    constraint {
      attribute = "${node.unique.name}"
      value = "nomad-client-2p1f"
    }

    network {
      mode = "bridge"

      port "api" {
        to = 9200
        static = 9200
      }

      port "cluster" {
        to = 9201
      }
      
      port "proxy" {
        to = 9202
      }
      
      port "postgres" {
        to = 5432
      }
    }

    service {
      name = "boundary"
      port = "9002"

      connect {
        sidecar_service {
          proxy {
            upstreams {
                destination_name = "cloudsql"
                local_bind_port = 5432
            }
          }
        }
      }
    }

    task "init" {
      driver = "docker"

      config {
        image   = "hashicorp/boundary:0.3.0"
        command = "boundary"
        args = [
            "database",
            "init",
            "-config=local/config.hcl"
        ]
      }

      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      resources {
        cpu    = 500
        memory = 256
      }

      env {
        BOUNDARY_ADDR = "http://localhost:9200"
      }

            template {
        destination = "local/config.hcl"
        data = <<EOF
disable_mlock = true

controller {
  name = "demo-controller-1"
  description = "A controller for a demo!"

  database {
    url = "postgresql://boundary:boundary@localhost:5432/boundary?sslmode=disable"
  }
}

worker {
  name = "demo-worker-1"
  description = "A default worker created demonstration"
  address = "127.0.0.1"
}

listener "tcp" {
  address = "127.0.0.1"
  purpose = "api"
  tls_disable = true 
}

listener "tcp" {
  address = "127.0.0.1"
  purpose = "cluster"
  tls_disable   = true 
}

listener "tcp" {
  address       = "127.0.0.1"
  purpose       = "proxy"
  tls_disable   = true 
}

kms "aead" {
  purpose = "root"
  aead_type = "aes-gcm"
  key = "uC8zAQ3sLJ9o0ZlH5lWIgxNZrNn0FiFqYj4802VKLKQ="
  key_id = "global_root"
}

kms "aead" {
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "cOQ9fiszFoxu/c20HbxRQ5E9dyDM6PqMY1GwqVLihsI="
  key_id = "global_worker-auth"
}

kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "nIRSASgoP91KmaEcg/EAaM4iAkksyB+Lkes0gzrLIRM="
  key_id = "global_recovery"
}
EOF
      }
    }

    task "boundary" {
      driver = "docker"

      config {
        privileged = true
        image   = "hashicorp/boundary:0.3.0"
        args    = [
          "server",
          "-config=local/config.hcl"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
      }

      env {
        BOUNDARY_ADDR = "http://localhost:9200"
      }

      template {
        destination = "local/config.hcl"
        destination = "local/config.hcl"
        data = <<EOF
disable_mlock = true

controller {
  name = "demo-controller-1"
  description = "A controller for a demo!"

  database {
    url = "postgresql://boundary:boundary@localhost:5432/boundary?sslmode=disable"
  }
}

worker {
  name = "demo-worker-1"
  description = "A default worker created demonstration"
  address = "127.0.0.1"
}

listener "tcp" {
  address = "0.0.0.0"
  purpose = "api"
  tls_disable = true 
}

listener "tcp" {
  address = "127.0.0.1"
  purpose = "cluster"
  tls_disable   = true 
}

listener "tcp" {
  address       = "0.0.0.0"
  purpose       = "proxy"
  tls_disable   = true 
}

kms "aead" {
  purpose = "root"
  aead_type = "aes-gcm"
  key = "uC8zAQ3sLJ9o0ZlH5lWIgxNZrNn0FiFqYj4802VKLKQ="
  key_id = "global_root"
}

kms "aead" {
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "cOQ9fiszFoxu/c20HbxRQ5E9dyDM6PqMY1GwqVLihsI="
  key_id = "global_worker-auth"
}

kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "nIRSASgoP91KmaEcg/EAaM4iAkksyB+Lkes0gzrLIRM="
  key_id = "global_recovery"
}
EOF
      }
    }
  }
}
