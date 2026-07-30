# ------------------------------------------------------------------------------
# Networking Resources (VPC and Subnets)
# ------------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  provider                = google.lab
  name                    = "vpc-demo-anz"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  provider      = google.lab
  name          = "australia-southeast1"
  region        = var.lab_region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.1.0/24"
}

resource "google_compute_subnetwork" "subnet_dr" {
  provider      = google.lab
  name          = "australia-southeast2"
  region        = "australia-southeast2"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.2.0/24"
}

# ------------------------------------------------------------------------------
# Private Service Access (PSA) for Cloud SQL Private IP
# ------------------------------------------------------------------------------

resource "google_compute_global_address" "private_ip_alloc" {
  provider      = google.lab
  name          = "google-managed-services-vpc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta.lab
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# ------------------------------------------------------------------------------
# Cloud SQL SQL Server (MSSQL) Instance
# ------------------------------------------------------------------------------

resource "google_sql_database_instance" "mssql" {
  provider         = google.lab
  name             = "argo-demo-mssql-1"
  database_version = "SQLSERVER_2025_STANDARD"
  region           = var.lab_region

  root_password = var.mssql_root_password

  settings {
    collation         = "SQL_Latin1_General_CP1_CI_AS"
    tier              = "db-custom-2-8192"
    availability_type = "REGIONAL"
    disk_size         = 100

    user_labels = {
      env = "production"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.self_link
    }

    backup_configuration {
      enabled = false
    }
  }

  deletion_protection = true

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# ------------------------------------------------------------------------------
# Databases
# ------------------------------------------------------------------------------

resource "google_sql_database" "database1" {
  provider = google.lab
  name     = "Database1"
  instance = google_sql_database_instance.mssql.name
}

resource "google_sql_database" "database2" {
  provider = google.lab
  name     = "Database2"
  instance = google_sql_database_instance.mssql.name
}
