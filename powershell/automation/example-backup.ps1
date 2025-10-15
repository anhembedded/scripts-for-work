# Example: Automated Backup Script
# This script demonstrates a basic backup automation

param(
    [string]$SourcePath = "C:\Data",
    [string]$BackupPath = "C:\Backup",
    [switch]$Compress
)

# Import logger module
Import-Module "$PSScriptRoot\..\modules\Logger.psm1"

Write-Log "Starting backup process" -Level INFO
Write-Log "Source: $SourcePath" -Level INFO
Write-Log "Destination: $BackupPath" -Level INFO

try {
    # Check if source exists
    if (-not (Test-Path $SourcePath)) {
        throw "Source path does not exist: $SourcePath"
    }
    
    # Create backup directory
    if (-not (Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
        Write-Log "Created backup directory: $BackupPath" -Level INFO
    }
    
    # Generate timestamp for backup
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupName = "backup-$timestamp"
    
    if ($Compress) {
        # Create compressed backup
        $zipPath = Join-Path $BackupPath "$backupName.zip"
        Compress-Archive -Path $SourcePath -DestinationPath $zipPath -Force
        Write-Log "Compressed backup created: $zipPath" -Level INFO
    } else {
        # Copy files
        $destPath = Join-Path $BackupPath $backupName
        Copy-Item -Path $SourcePath -Destination $destPath -Recurse -Force
        Write-Log "Backup copied to: $destPath" -Level INFO
    }
    
    Write-Log "Backup completed successfully" -Level INFO
}
catch {
    Write-Log "Backup failed: $_" -Level ERROR
    exit 1
}
