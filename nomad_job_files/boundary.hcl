job "boundary-controller" {

  datacenters = ["dc1", "dc2", "dc3"]
  type = "service"

  group "controllers" {

    count = 3

    spread {
      attribute = "${nomad.datacenter}"
      weight    = 100
    }

    network {
      mode = "host"
    }

    update {
      max_parallel = 1
    }

    task "controller" {
      driver = "exec"
      args   = ["-config=/boundary/config.hcl"]

      artefact {
        source = "https://releases.hashicorp.com/boundary/0.1.7/boundary_0.1.7_darwin_amd64.zip"
      }
      config {
          command = "server"

        port_map {
          http = 9200
          api = 9201
          clustering = 9202
        }
      }
      resources {
        network {
          port "http" { static = 9200 }
          port "api" { static = 9201 }
          port "clustering" { static = 9202 }
        }
      }

      service {
        name = "boundary"
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}