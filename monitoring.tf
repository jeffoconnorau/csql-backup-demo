# ------------------------------------------------------------------------------
# Monitoring Notification Channel (Email)
# ------------------------------------------------------------------------------

resource "google_monitoring_notification_channel" "email" {
  provider     = google.backup
  project      = var.backup_project_id
  display_name = "GCBDR Operations Email Alerts"
  type         = "email"
  labels = {
    email_address = "jeff@glabco.com"
  }
}

# ------------------------------------------------------------------------------
# Alert Policy: Backup Event Failures
# ------------------------------------------------------------------------------

resource "google_monitoring_alert_policy" "backup_failure_alert" {
  provider     = google.backup
  project      = var.backup_project_id
  display_name = "GCBDR Backup Failure Alert"
  combiner     = "OR"
  conditions {
    display_name = "Backup Event Failure Log Match"
    condition_matched_log {
      filter = "resource.type=\"audited_resource\" AND protoPayload.serviceName=\"backupdr.googleapis.com\" AND protoPayload.methodName:\"Backup\" AND severity>=ERROR"
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

# ------------------------------------------------------------------------------
# Alert Policy: Restore Event Success/Failure
# ------------------------------------------------------------------------------

resource "google_monitoring_alert_policy" "restore_event_alert" {
  provider     = google.backup
  project      = var.backup_project_id
  display_name = "GCBDR Restore Event Success/Failure Alert"
  combiner     = "OR"
  conditions {
    display_name = "Restore Event Log Match"
    condition_matched_log {
      filter = "resource.type=\"audited_resource\" AND protoPayload.serviceName=\"backupdr.googleapis.com\" AND protoPayload.methodName:\"Restore\""
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}
