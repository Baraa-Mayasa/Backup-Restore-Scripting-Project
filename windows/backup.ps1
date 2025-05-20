# Define paths
$sourceFolder = "C:\Users\baraa\Documents\ImportantData"
$backupFolder = "C:\Users\baraa\Documents\Backups"

# Create backup folder if it doesn't exist
if (!(Test-Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder
}

# Create backup filename with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$backupFile = "$backupFolder\backup_$timestamp.zip"

# Compress the folder
Compress-Archive -Path $sourceFolder -DestinationPath $backupFile

Write-Output "Backup completed: $backupFile"
