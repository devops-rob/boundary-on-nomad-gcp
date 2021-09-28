variable "cloudsql_path" {
  type = string
  default = "/alloc/data/cloudsql"
}

variable "cloudsql_host" {
  type = string
  default = ""
}

variable "cloudsql_credentials" {
  type = string
  default = ""
}

job "cloudsql" {
  datacenters = ["dc1"]

  group "proxy" {
    network {
      mode = "bridge"

      port "sql" {
        to = 5432
      }
    }

    count = 3

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    service {
      name = "cloudsql"
      port = "5432"

      // connect {
      //   sidecar_service {}
      // }
    }

    task "proxy" {
      driver = "docker"

      template {
        data = var.cloudsql_credentials
        destination = "local/config"
      }

      config {
        image = "gcr.io/cloudsql-docker/gce-proxy:1.19.1"
        args = [
          "/cloud_sql_proxy", 
          "-instances=${var.cloudsql_host}=tcp:0.0.0.0:5432",
          "-credential_file=/config",
        ]
        volumes = ["local/config:/config"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
