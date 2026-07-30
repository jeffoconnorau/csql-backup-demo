#!/bin/bash
# Script to rebuild the lost argo-svc-dev terraform.tfstate file
set -e

LAB_PROJECT="argo-svc-dev-3"
BACKUP_PROJECT="argo-svc-dev-4"
REGION="australia-southeast1"

echo "=== Importing GCBDR Core Resources ==="
terraform import google_backup_dr_backup_vault.vault_sydney "projects/${BACKUP_PROJECT}/locations/${REGION}/backupVaults/bv-australia-southeast1" || true
terraform import google_backup_dr_backup_plan.mssql_bp "projects/${BACKUP_PROJECT}/locations/${REGION}/backupPlans/mssql-backup-plan" || true
terraform import google_backup_dr_backup_plan.mssql_nonprod_bp "projects/${BACKUP_PROJECT}/locations/${REGION}/backupPlans/mssql-nonprod-backup-plan" || true
terraform import google_backup_dr_backup_plan_association.mssql_association "projects/${LAB_PROJECT}/locations/${REGION}/backupPlanAssociations/plan-association-mssql" || true

echo "=== Re-importing Cloud SQL MSSQL ==="
terraform import google_sql_database_instance.mssql "projects/${LAB_PROJECT}/instances/argo-demo-mssql-1" || true
terraform import google_sql_database.database1 "projects/${LAB_PROJECT}/instances/argo-demo-mssql-1/databases/Database1" || true
terraform import google_sql_database.database2 "projects/${LAB_PROJECT}/instances/argo-demo-mssql-1/databases/Database2" || true

echo "=== State Recovery Finished ==="
