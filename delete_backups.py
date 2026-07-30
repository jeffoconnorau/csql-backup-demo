import subprocess
import json
import concurrent.futures
import sys

PROJECT = "backup-project"
LOCATION = "australia-southeast1"
VAULT = "bv-australia-southeast1"

def run_command(cmd):
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        raise Exception(f"Command failed: {' '.join(cmd)}\nError: {result.stderr}")
    return result.stdout

def get_data_sources():
    print("Fetching data sources...")
    cmd = [
        "gcloud", "backup-dr", "data-sources", "list",
        f"--project={PROJECT}", f"--location={LOCATION}", f"--backup-vault={VAULT}",
        "--format=json"
    ]
    output = run_command(cmd)
    ds_list = json.loads(output)
    return [ds['name'].split('/')[-1] for ds in ds_list]

def get_backups(ds_id):
    print(f"Fetching backups for data source {ds_id}...")
    cmd = [
        "gcloud", "backup-dr", "backups", "list",
        f"--project={PROJECT}", f"--location={LOCATION}", f"--backup-vault={VAULT}",
        f"--data-source={ds_id}",
        "--format=json"
    ]
    output = run_command(cmd)
    backup_list = json.loads(output)
    return [b['name'].split('/')[-1] for b in backup_list]

def delete_backup(ds_id, backup_id):
    print(f"Deleting backup {backup_id} from datasource {ds_id}...")
    cmd = [
        "gcloud", "backup-dr", "backups", "delete", backup_id,
        f"--project={PROJECT}", f"--location={LOCATION}", f"--backup-vault={VAULT}",
        f"--data-source={ds_id}",
        "--quiet", "--async"
    ]
    try:
        run_command(cmd)
        return True, ds_id, backup_id
    except Exception as e:
        return False, ds_id, backup_id, str(e)

def main():
    try:
        data_sources = get_data_sources()
        print(f"Found {len(data_sources)} data sources.")
        
        all_backups = []
        for ds in data_sources:
            try:
                backups = get_backups(ds)
                print(f"Data source {ds} has {len(backups)} backups.")
                for b in backups:
                    all_backups.append((ds, b))
            except Exception as e:
                print(f"Failed to get backups for data source {ds}: {e}")
                
        print(f"Total backups to delete: {len(all_backups)}")
        if not all_backups:
            print("No backups found to delete.")
            return

        print("Starting parallel deletion...")
        success_count = 0
        fail_count = 0
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
            futures = [executor.submit(delete_backup, ds, b) for ds, b in all_backups]
            for future in concurrent.futures.as_completed(futures):
                res = future.result()
                if res[0]:
                    success_count += 1
                else:
                    fail_count += 1
                    print(f"Failed to delete {res[2]} from {res[1]}: {res[3]}")
                    
        print(f"Deletion complete. Successes: {success_count}, Failures: {fail_count}")

    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
