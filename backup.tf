# ------------------------------------------------------------------------------
# Backup Vault (Sydney Location)
# ------------------------------------------------------------------------------
resource "google_backup_dr_backup_vault" "vault_sydney" {
  provider                                   = google-beta.backup
  location                                   = "australia-southeast1"
  backup_vault_id                            = "bv-australia-southeast1"
  description                                = "Sydney based backup vault"
  backup_minimum_enforced_retention_duration = "86400s" # 1 day
}

# ------------------------------------------------------------------------------
# IAM permissions for GCBDR Backup Vaults to access Workload Cloud SQL
# ------------------------------------------------------------------------------
resource "google_project_iam_member" "vault_sydney_cloudsql_admin" {
  provider = google.lab
  project  = var.lab_project_id
  role     = "roles/cloudsql.admin"
  member   = "serviceAccount:${google_backup_dr_backup_vault.vault_sydney.service_account}"
}


# ------------------------------------------------------------------------------
# Backup Plan for Cloud SQL
# ------------------------------------------------------------------------------
resource "google_backup_dr_backup_plan" "mssql_bp" {
  provider       = google-beta.backup
  location       = var.backup_plan_region
  backup_plan_id = "mssql-backup-plan"
  description    = "Cloud SQL MSSQL GCBDR Backup Plan"
  resource_type  = "sqladmin.googleapis.com/Instance"
  backup_vault   = google_backup_dr_backup_vault.vault_sydney.id

  log_retention_days = 7

  # 14 days of daily backups
  backup_rules {
    rule_id               = "daily"
    backup_retention_days = 14
    standard_schedule {
      recurrence_type = "DAILY"
      time_zone       = "Australia/Sydney"
      backup_window {
        start_hour_of_day = 0
        end_hour_of_day   = 6
      }
    }
  }

  # 4 weeks of weeklies
  backup_rules {
    rule_id               = "weekly"
    backup_retention_days = 28
    standard_schedule {
      recurrence_type = "WEEKLY"
      days_of_week    = ["SUNDAY"]
      time_zone       = "Australia/Sydney"
      backup_window {
        start_hour_of_day = 0
        end_hour_of_day   = 6
      }
    }
  }

  # 3 months of monthlies
  backup_rules {
    rule_id               = "monthly"
    backup_retention_days = 90
    standard_schedule {
      recurrence_type = "MONTHLY"
      days_of_month   = [1]
      time_zone       = "Australia/Sydney"
      backup_window {
        start_hour_of_day = 0
        end_hour_of_day   = 6
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Backup Plan for Non-Production Cloud SQL
# ------------------------------------------------------------------------------
resource "google_backup_dr_backup_plan" "mssql_nonprod_bp" {
  provider       = google-beta.backup
  location       = var.backup_plan_region
  backup_plan_id = "mssql-nonprod-backup-plan"
  description    = "Cloud SQL MSSQL GCBDR Backup Plan (Non-Production)"
  resource_type  = "sqladmin.googleapis.com/Instance"
  backup_vault   = google_backup_dr_backup_vault.vault_sydney.id

  log_retention_days = 1

  # 7 days of daily backups
  backup_rules {
    rule_id               = "daily"
    backup_retention_days = 7
    standard_schedule {
      recurrence_type = "DAILY"
      time_zone       = "Australia/Sydney"
      backup_window {
        start_hour_of_day = 0
        end_hour_of_day   = 6
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Backup Plan Association for Cloud SQL
# ------------------------------------------------------------------------------
resource "google_backup_dr_backup_plan_association" "mssql_association" {
  provider                   = google-beta.lab
  location                   = var.lab_region
  backup_plan_association_id = "plan-association-mssql"
  resource_type              = "sqladmin.googleapis.com/Instance"
  resource                   = "projects/${var.lab_project_id}/instances/${google_sql_database_instance.mssql.name}"
  backup_plan                = google_backup_dr_backup_plan.mssql_bp.id

  depends_on = [
    google_project_iam_member.vault_sydney_cloudsql_admin
  ]
}
