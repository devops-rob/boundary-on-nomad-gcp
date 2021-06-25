# ---------------------------------------------------------
# CREATE PRIMARY DATABASE INSTANCE
# ---------------------------------------------------------

resource "random_id" "primary_db" {
  byte_length = 4
}

resource "google_sql_database_instance" "primary_db" {
  //  provider = google-beta

  name   = "primary-db-${random_id.primary_db.hex}"
  region = var.region


  database_version = "POSTGRES_12"
  //  encryption_key_name = google_kms_crypto_key.database_key.id
  deletion_protection = false


  settings {
    tier              = "db-g1-small" // This must be a shared core machine type
    availability_type = "REGIONAL"

    location_preference {
      zone = "${var.region}-a"
    }

    disk_autoresize = true
    disk_type       = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.id
      require_ssl     = false

    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      location                       = var.region
      binary_log_enabled = true
    }

  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_sql_database" "boundary" {
  instance = google_sql_database_instance.primary_db.name
  name     = "boundary-default"
}

resource "google_sql_user" "users" {
  name     = "me"
  instance = google_sql_database_instance.primary_db.name
  type     = "BUILT_IN"
  password = "TestPasswordForPSQL12"
}


# ---------------------------------------------------------
# CREATE READ REPLICA INSTANCE
# ---------------------------------------------------------

resource "google_sql_database_instance" "read_replica_db" {
  //  provider = google-beta

  name   = "primary-db-${random_id.primary_db.hex}-replica"
  region = var.region


  database_version = "POSTGRES_12"
  //  encryption_key_name = google_kms_crypto_key.database_key.id
  deletion_protection = false


  settings {
    tier              = "db-g1-small"
    availability_type = "ZONAL"

    location_preference {
      zone = "${var.region}-b"
    }

    disk_autoresize = true
    disk_type       = "PD_SSD"

    activation_policy = "ALWAYS"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.id
      require_ssl     = false
    }

    backup_configuration {
      binary_log_enabled = false
    }
  }

  master_instance_name = google_sql_database_instance.primary_db.id

  replica_configuration {
    failover_target = true
    username = google_sql_user.users.name
    password = google_sql_user.users.password
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_sql_database.boundary
  ]
}

