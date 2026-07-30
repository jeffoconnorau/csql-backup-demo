# ------------------------------------------------------------------------------
# Existing Network Data Sources
# ------------------------------------------------------------------------------
data "google_compute_network" "vpc" {
  name = var.vpc_name
}

data "google_compute_subnetwork" "subnet" {
  name   = var.subnet_name
  region = var.clone_region
}

# ------------------------------------------------------------------------------
# Clone/Restore Cloud SQL MSSQL Instance for Dev/Test
# ------------------------------------------------------------------------------
resource "google_sql_database_instance" "cloned_mssql" {
  count            = var.mssql_backup_run_id != null ? 1 : 0
  provider         = google-beta
  name             = var.cloned_instance_name
  region           = var.clone_region
  database_version = "SQLSERVER_2025_STANDARD"
  root_password    = var.mssql_root_password

  restore_backup_context {
    backup_run_id = var.mssql_backup_run_id
    instance_id   = "argo-demo-mssql-1"
    project       = var.lab_project_id
  }

  settings {
    tier              = var.mssql_tier
    disk_size         = var.mssql_disk_size
    disk_type         = "PD_SSD"
    availability_type = "ZONAL"

    user_labels = {
      env = "dev"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.vpc.id
    }
  }

  deletion_protection = false
}
