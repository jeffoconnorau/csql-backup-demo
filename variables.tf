variable "backup_project_id" {
  type        = string
  description = "The project ID containing GCBDR vaults and plans"
  default     = "argo-svc-dev-4"
}

variable "lab_project_id" {
  type        = string
  description = "The project ID containing the virtual machines"
  default     = "argo-svc-dev-3"
}

variable "backup_vault_region" {
  type        = string
  description = "The region for the GCBDR backup vault"
  default     = "australia-southeast1"
}

variable "backup_plan_region" {
  type        = string
  description = "The region for the GCBDR backup plans"
  default     = "australia-southeast1"
}

variable "lab_region" {
  type        = string
  description = "The region for lab resources"
  default     = "australia-southeast1"
}

variable "lab_zone" {
  type        = string
  description = "The zone for lab resources"
  default     = "australia-southeast1-a"
}

variable "lab_project_number" {
  type        = string
  description = "The project number of the lab project"
  default     = "901938564126"
}

variable "mssql_root_password" {
  type        = string
  description = "The root password for the Cloud SQL SQL Server instance"
  default     = "MeityBackupDR2026!"
  sensitive   = true
}
