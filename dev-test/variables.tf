variable "backup_project_id" {
  type        = string
  description = "The project ID containing GCBDR vaults and plans"
  default     = "backup-project"
}

variable "lab_project_id" {
  type        = string
  description = "The project ID containing the virtual machines"
  default     = "workload-project"
}

variable "backup_vault_region" {
  type        = string
  description = "The region of the GCBDR backup vault"
  default     = "australia-southeast1"
}

variable "backup_vault_id" {
  type        = string
  description = "The backup vault name/id"
  default     = "bv-australia-southeast1"
}

variable "clone_region" {
  type        = string
  description = "The target region for cloned instances"
  default     = "australia-southeast1"
}

variable "clone_zone" {
  type        = string
  description = "The target zone for cloned instances"
  default     = "australia-southeast1-a"
}

variable "vpc_name" {
  type        = string
  description = "The VPC network name"
  default     = "vpc-demo-anz"
}

variable "subnet_name" {
  type        = string
  description = "The subnet name in the target region"
  default     = "australia-southeast1"
}

variable "mssql_backup_run_id" {
  type        = number
  description = "The backup run ID of the Cloud SQL SQL Server instance to restore"
  default     = null
}

variable "mssql_root_password" {
  type        = string
  description = "The root password for the cloned SQL Server instance"
  default     = "DevTestClone2026!"
  sensitive   = true
}

variable "mssql_tier" {
  type        = string
  description = "The database instance tier for the cloned instance"
  default     = "db-custom-8-32768"
}

variable "cloned_instance_name" {
  type        = string
  description = "The name of the cloned SQL database instance"
  default     = "dev-argo-demo-mssql-1"
}

variable "mssql_disk_size" {
  type        = number
  description = "The disk size in GB for the cloned instance"
  default     = 100
}

