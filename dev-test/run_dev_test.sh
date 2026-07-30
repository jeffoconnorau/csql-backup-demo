#!/bin/bash
set -e

# Navigate to the script's directory
CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$CDIR"

# Determine action (plan, apply, or destroy) and collect extra arguments
ACTION="plan"
EXTRA_ARGS=()
if [[ "$1" == "--apply" ]]; then
  ACTION="apply"
  EXTRA_ARGS=("${@:2}")
elif [[ "$1" == "--destroy" ]]; then
  ACTION="destroy"
  EXTRA_ARGS=("${@:2}")
else
  EXTRA_ARGS=("$@")
fi

echo "========================================================================="
if [[ "$ACTION" == "destroy" ]]; then
  echo "Step 1: Destroying dev-test cloned workloads..."
  terraform destroy -auto-approve -var-file=dev_backups.tfvars "${EXTRA_ARGS[@]}"
  exit 0
fi

echo "Step 1: Dynamically discovering latest SQL backups..."
python3 scripts/generate_tfvars.py

echo "========================================================================="
if [[ "$ACTION" == "apply" ]]; then
  echo "Step 2: Executing restore/clone operations (apply)..."
  APPLY_START=$(date +%s)
  
  terraform apply -auto-approve -var-file=dev_backups.tfvars "${EXTRA_ARGS[@]}"
  
  APPLY_END=$(date +%s)

  echo "========================================================================="
  echo "Step 3: Compiling Automated Dev-Test Verification Report..."
  sleep 2
  python3 scripts/generate_report.py "$APPLY_START" "$APPLY_END"
else
  echo "Step 2: Planning clone operations (plan)..."
  terraform plan -var-file=dev_backups.tfvars "${EXTRA_ARGS[@]}"
fi
