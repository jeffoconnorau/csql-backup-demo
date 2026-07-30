import sys
import json
import subprocess
import os

def run_command(args):
    # Set CLOUDSDK_PYTHON to system python3 to bypass virtualenv issue
    env = {"CLOUDSDK_PYTHON": "/usr/local/bin/python3"}
    env.update(os.environ)
    result = subprocess.run(args, env=env, capture_output=True, text=True)
    if result.returncode != 0:
        raise Exception(f"Command failed: {' '.join(args)}\nStderr: {result.stderr}")
    return result.stdout

def main():
    try:
        lab_project = "argo-svc-dev-3"
        backup_project = "argo-svc-dev-4"
        vault_region = "australia-southeast2"
        vault_id = "bv-australia-southeast2"
        mssql_name = "argo-demo-mssql-1"
        
        print("Resolving Cloud SQL MSSQL backup run ID...")
        mssql_backup_run_id = None
        mssql_create_time = "N/A"
        try:
            sql_args = [
                "gcloud", "sql", "backups", "list",
                "--instance", mssql_name,
                "--project", lab_project,
                "--format", "json"
            ]
            sql_output = run_command(sql_args)
            sql_backups = json.loads(sql_output)
            
            # Filter for SUCCESSFUL backups
            successful_backups = [b for b in sql_backups if b.get("status") == "SUCCESSFUL"]
            if successful_backups:
                # Sort by creation time / id descending
                successful_backups.sort(key=lambda x: int(x.get("id", 0)), reverse=True)
                latest_sql_bu = successful_backups[0]
                mssql_backup_run_id = int(latest_sql_bu["id"])
                mssql_create_time = latest_sql_bu.get("windowStartTime", "N/A")
                print(f"Resolved native backup run ID for MSSQL {mssql_name}: {mssql_backup_run_id}, created={mssql_create_time}")
            else:
                print(f"Warning: No successful native backups found for MSSQL {mssql_name}")
        except Exception as sql_ex:
            print(f"Warning: Failed to fetch Cloud SQL backups: {str(sql_ex)}")

        # Generate tfvars content
        tfvars_lines = ["# Auto-generated recovery points for dev-test clone testing"]
        if mssql_backup_run_id:
            tfvars_lines.append(f"mssql_backup_run_id = {mssql_backup_run_id}")
        else:
            tfvars_lines.append("mssql_backup_run_id = null")
        
        # Write to dev_backups.tfvars
        output_path = os.path.join(os.path.dirname(__file__), "..", "dev_backups.tfvars")
        with open(output_path, "w") as f:
            f.write("\n".join(tfvars_lines) + "\n")
        print(f"Successfully wrote HCL variables to {os.path.abspath(output_path)}")

        # Write to dev_backups.json
        json_output = {
            "mssql": {
                "backup_run_id": mssql_backup_run_id,
                "backup_create_time": mssql_create_time
            } if mssql_backup_run_id else None
        }
        json_path = os.path.join(os.path.dirname(__file__), "..", "dev_backups.json")
        with open(json_path, "w") as f:
            json.dump(json_output, f, indent=2)
        print(f"Successfully wrote JSON copy to {os.path.abspath(json_path)}")
        
    except Exception as e:
        print(f"Error generating tfvars: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
