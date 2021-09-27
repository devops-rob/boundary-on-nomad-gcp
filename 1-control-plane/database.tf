resource "random_id" "database" {
  byte_length = 8
}

resource "google_sql_database_instance" "database" {
  name             = "${var.database_instance_prefix}-${random_id.database.hex}"
  database_version = var.database_instance_version
  region           = var.project_region

  settings {
    tier = var.database_instance_type
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  for_each = toset(var.database_names)
  name     = each.key
  instance = google_sql_database_instance.database.name
}

resource "random_password" "default" {
  length           = 32
  special          = true
  override_special = "_%@"
}

resource "google_sql_user" "boundary" {
  name     = "boundary"
  instance = google_sql_database_instance.database.name
  password = "boundary"
}

resource "google_service_account" "cloudsql_proxy" {
  account_id   = "cloudsql-proxy"
  display_name = "Cloud SQL Proxy"
}

resource "google_service_account_key" "cloudsql_proxy" {
  service_account_id = google_service_account.cloudsql_proxy.name
}

resource "google_project_iam_member" "cloudsql_proxy" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}

resource "nomad_job" "cloudsql" {
  hcl2 {
    enabled = true
    vars = {
      "cloudsql_path"        = "/alloc/data/cloudsql",
      "cloudsql_host"        = "${var.project_id}:${var.project_region}:${google_sql_database_instance.database.name}",
      "cloudsql_credentials" = base64decode(google_service_account_key.cloudsql_proxy.private_key)
    }
  }

  jobspec = file("${path.module}/jobs/cloudsql.nomad")

  depends_on = [
    null_resource.nomad_race_condition
  ]
}

resource "null_resource" "nomad_race_condition" {

  provisioner "local-exec" {

    command = "sleep 180"

  }

  depends_on = [
    # consul_acl_policy.nomad_server,
    # consul_acl_token.nomad_server,
    google_compute_firewall.nomad_allow_whitelist,
    google_compute_forwarding_rule.nomad_server_internal,
    google_compute_health_check.nomad,
    google_compute_http_health_check.nomad,
    google_compute_instance_template.boundary_controller,
    google_compute_instance_template.nomad_server,
    google_compute_region_backend_service.nomad_server,
    google_compute_region_instance_group_manager.boundary_controller,
    google_compute_region_instance_group_manager.nomad_server,
    google_compute_target_pool.nomad_server,
    google_compute_target_pool.boundary_controller
  ]
}

output "database_user" {
  value     = google_sql_user.boundary.name
  sensitive = true
}

output "database_password" {
  value     = google_sql_user.boundary.password
  sensitive = true
}

output "database_host" {
  value     = "${var.project_id}:${var.project_region}:${google_sql_database_instance.database.name}"
  sensitive = true
}

output "cloudsql_credentials" {
  value     = base64decode(google_service_account_key.cloudsql_proxy.private_key)
  sensitive = true
}
