# Feasibility Study: Supporting `rclone` as a Storage Backend in DRS

This document analyzes the possibility and design requirements of adding [rclone](https://rclone.org/) support as a cloud-storage backend (e.g. S3, GCS, Azure Blob, OneDrive, Dropbox, SFTP) to DRS while maintaining the minimalistic, script-based simplicity of the codebase.

---

## Why `rclone`?

`rclone` is often referred to as *"rsync for cloud storage."* It supports standard sync, copy, list, and delete operations across 40+ storage providers. 

### Benefits for DRS:
1. **Cloud Native**: Replaces the requirement for a dedicated Unix server (SSH + rsync) with affordable cloud object storage (Amazon S3, Backblaze B2, Google Cloud Storage).
2. **Server-Side Copies**: Supports fast server-side copies (duplicating files within a bucket without local bandwidth), matching the speed of the baseline-rev SSH copy (`cp -R -a`).
3. **No SSH requirement**: Expands compatibility to Windows and other environments where configuring SSH keys and permissions can be complex.
4. **Client-Side Cleanup**: Cleanup operations can be run directly from any client machine using `rclone delete`/`purge`, removing the need for server-side setup or cron jobs.

---

## Configuration Comparison

To keep `drs` simple, we can introduce a `backend` flag in `drs.json`. If omitted, it defaults to `"ssh"` (current behavior).

### Current configuration (`ssh` backend):
```json
{
  "backend": "ssh",
  "remote": {
    "host": "drs-server",
    "path": "/volume1/storage/project"
  }
}
```

### Proposed configuration (`rclone` backend):
```json
{
  "backend": "rclone",
  "remote": {
    "name": "my-s3-bucket",
    "path": "drs-project"
  }
}
```
*Note: Authentication and endpoint parameters can either be managed in a standard `rclone.conf` config file, or defined as a **fully static, config-free configuration** via environment variables (e.g. `RCLONE_S3_ACCESS_KEY_ID=...`) or inline connection strings (e.g. `:s3,provider=Minio,endpoint="http://localhost:9000",access_key_id=X,secret_access_key=Y:bucket/path`).*

---

## Command Mappings

Here is how the core actions translate between the `ssh` / `rsync` backend and the `rclone` backend:

| Action | Current `ssh/rsync` Command | Proposed `rclone` Command |
| :--- | :--- | :--- |
| **Check Rev Existence** | `ssh "$host" "[ -d $path/$uuid ]"` | `rclone size "$name:$path/$uuid"` *(errors if empty/missing)* |
| **Put Revision** | `rsync -a --delete-during "$src/" "$host:$path/$uuid/"` | `rclone sync "$src" "$name:$path/$uuid" --progress` |
| **Get Revision** | `rsync -a --delete-during "$host:$path/$uuid/" "$target/"` | `rclone sync "$name:$path/$uuid" "$target" --progress` |
| **Duplicate Baseline** | `ssh "$host" cp -R -a "$path/$last_uuid" "$path/$uuid"` | `rclone copy "$name:$path/$last_uuid" "$name:$path/$uuid" --server-side-across-configs` |
| **Check Total Size** | `ssh "$host" "du -sh $path"` | `rclone size "$name:$path"` |
| **Delete Revision** | *(Server-side cleanup)* `rm -rf "$path/$uuid"` | `rclone purge "$name:$path/$uuid"` |

---

## How to Implement Simple Abstraction

To avoid complicating the client scripts (`put.sh`, `get.sh`, `usage.sh`), we can define wrapper functions inside `src/common.sh`.

For example, we can introduce transport helpers:

```bash
# In src/common.sh

# Check if a directory revision exists
function drs::transport::exists() {
  local backend=$(jq -r '.backend // "ssh"' "${DRS_CONFIG_FILE}")
  if [[ "$backend" == "rclone" ]]; then
    rclone size "$remote_name:$remote_path/$1" >/dev/null 2>&1
  else
    ssh "${host}" "[ -d ${path}/${1} ]"
  fi
}

# Sync local workspace to remote
function drs::transport::put() {
  local backend=$(jq -r '.backend // "ssh"' "${DRS_CONFIG_FILE}")
  if [[ "$backend" == "rclone" ]]; then
    rclone sync "$1" "$remote_name:$remote_path/$2"
  else
    rsync $rsyncOptions -e 'ssh -T' "$1/" "${host}:${path}/${2}/"
  fi
}
```

By abstracting these operations, `put.sh` and `get.sh` remain clean:
* `put.sh` calls `drs::transport::put "${source_directory}" "${uuid}"`
* `get.sh` calls `drs::transport::exists "${uuid}"` and then `drs::transport::get "${uuid}" "${target_directory}"`

---

## Architectural Challenges

While simple in concept, there is only one minor challenge to address:

1. **Space Breakdown in `usage.sh`**:
   `du` isn't directly available in standard cloud bucket APIs. 
   * **Solution**: We can parse the output of `rclone lsjson --max-depth 1 "$name:$path"` to fetch direct child sizes, or run `rclone size` on subfolders.
2. **Missing Filesystem Disk Space**:
   * **Resolved**: By establishing a common ground of occupied space only and removing the remote disk partition free space query (`df`) from the `usage` command, this is no longer a challenge. All backends now share the exact same clean schema.

---

## Conclusion & Feasibility Rating

* **Feasibility**: **9/10** (Highly feasible)
* **Code Complexity Impact**: **Low** (Adds ~80 lines of wrapper functions in `common.sh` and lets us delete/simplify server-side script setup dependencies for cloud deployments).

This is a great path forward if cloud integrations are required, as it preserves DRS's simplicity without adding complex dependencies.
