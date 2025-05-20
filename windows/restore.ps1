# Define paths
$backupFolder = "C:\Users\baraa\Documents\Backups"
$restoreFolder = "C:\Users\baraa\Documents\RestoreImportantData"

# List all backup ZIP files and sort by newest first
$backups = Get-ChildItem -Path $backupFolder -Filter "*.zip" | Sort-Object LastWriteTime -Descending

# Get the most recent backup
$latestBackup = $backups[0].FullName

# Confirm the backup exists
if (-not (Test-Path $latestBackup)) {
    Write-Error "No backup file found in $backupFolder"
    exit
}

# Optional: Clear the current contents of the restore folder
if (Test-Path $restoreFolder) {
    Remove-Item "$restoreFolder\*" -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $restoreFolder
}

# Extract the backup zip
Expand-Archive -Path $latestBackup -DestinationPath $restoreFolder

Write-Output "Restore completed from: $latestBackup"
