---

##  Flash Drive Backup Script (`usb_backup.sh`)

This script is a **dedicated solution for incremental backups** from a local directory to a USB flash drive using `rsync`.

### ✅ Features

- **Incremental Backup**: Uses `rsync` to copy only changed files for efficiency.
- **Flash Drive Friendly**: Designed to work reliably with mounted removable USB storage.
- **Cron-Compatible**: Can be scheduled using `cron` for routine execution.
- **Simple Logging**: Outputs to a `.log` file for easy troubleshooting.

### 🛠️ Requirements

- A mounted flash drive (e.g., `/media/<user>/YourDriveName`)
- `rsync` must be installed (`sudo apt install rsync`)
- The script must be executable (`chmod +x usb_backup.sh`)

### 🕐 Example Cron Job

To run the backup every minute to keep the files up-to-date:

```cron
* * * * * /path/to/usb_backup.sh >> /path/to/usb_backup.log 2>&1
