# Drive Health Check Script
# Checks all connected drives for health and status

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DRIVE HEALTH CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get all volumes with drive letters
Write-Host "--- CONNECTED DRIVES ---" -ForegroundColor Yellow
try {
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }
    if ($volumes) {
        foreach ($vol in $volumes) {
            $sizeGB = [math]::Round($vol.Size / 1GB, 2)
            $freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)
            $usedGB = [math]::Round(($vol.Size - $vol.SizeRemaining) / 1GB, 2)
            $percentFree = [math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 1)
            
            $healthColor = if ($vol.HealthStatus -eq "Healthy") { "Green" } else { "Red" }
            
            Write-Host "Drive: $($vol.DriveLetter):" -ForegroundColor Green
            Write-Host "  Label: $($vol.FileSystemLabel)"
            Write-Host "  File System: $($vol.FileSystemType)"
            Write-Host "  Total Size: $sizeGB GB"
            Write-Host "  Used: $usedGB GB"
            Write-Host "  Free: $freeGB GB ($percentFree%)"
            Write-Host "  Health Status: $($vol.HealthStatus)" -ForegroundColor $healthColor
            Write-Host "  Operational Status: $($vol.OperationalStatus)"
            Write-Host ""
        }
    } else {
        Write-Host "No drives found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error retrieving volume info: $_" -ForegroundColor Red
}

# Get physical disks
Write-Host "--- PHYSICAL DISKS ---" -ForegroundColor Yellow
try {
    $disks = Get-Disk
    if ($disks) {
        foreach ($disk in $disks) {
            $sizeGB = [math]::Round($disk.Size / 1GB, 2)
            $healthColor = if ($disk.HealthStatus -eq "Healthy") { "Green" } else { "Red" }
            
            Write-Host "Disk $($disk.Number): $($disk.FriendlyName)" -ForegroundColor Green
            Write-Host "  Size: $sizeGB GB"
            Write-Host "  Partition Style: $($disk.PartitionStyle)"
            Write-Host "  Health Status: $($disk.HealthStatus)" -ForegroundColor $healthColor
            Write-Host "  Operational Status: $($disk.OperationalStatus)"
            Write-Host "  Bus Type: $($disk.BusType)"
            Write-Host ""
        }
    } else {
        Write-Host "No physical disks found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error retrieving disk info: $_" -ForegroundColor Red
}

# Check for USB/Removable drives
Write-Host "--- REMOVABLE/USB DRIVES ---" -ForegroundColor Yellow
try {
    $allVolumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }
    $removableVolumes = $allVolumes | Where-Object { $_.DriveType -eq 'Removable' }
    
    if ($removableVolumes) {
        foreach ($vol in $removableVolumes) {
            $sizeGB = [math]::Round($vol.Size / 1GB, 2)
            $freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)
            $usedGB = [math]::Round(($vol.Size - $vol.SizeRemaining) / 1GB, 2)
            
            Write-Host "Removable Drive: $($vol.DriveLetter):" -ForegroundColor Green
            Write-Host "  Label: $($vol.FileSystemLabel)"
            Write-Host "  File System: $($vol.FileSystemType)"
            Write-Host "  Size: $sizeGB GB"
            Write-Host "  Used: $usedGB GB"
            Write-Host "  Free: $freeGB GB"
            Write-Host "  Health: $($vol.HealthStatus)"
            Write-Host ""
        }
    } else {
        Write-Host "No removable/USB drives currently connected to this computer" -ForegroundColor Yellow
        Write-Host "(If you plugged a drive into your TV, it won't show here - check your TV)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error checking removable drives: $_" -ForegroundColor Red
}

# Check drive errors
Write-Host "--- DRIVE ERRORS CHECK ---" -ForegroundColor Yellow
try {
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }
    $hasErrors = $false
    foreach ($vol in $volumes) {
        if ($vol.HealthStatus -ne "Healthy") {
            Write-Host "WARNING: Drive $($vol.DriveLetter): Health Status = $($vol.HealthStatus)" -ForegroundColor Red
            $hasErrors = $true
        }
        if ($vol.OperationalStatus -ne "OK") {
            Write-Host "WARNING: Drive $($vol.DriveLetter): Operational Status = $($vol.OperationalStatus)" -ForegroundColor Red
            $hasErrors = $true
        }
    }
    if (-not $hasErrors) {
        Write-Host "All drives appear healthy!" -ForegroundColor Green
    }
} catch {
    Write-Host "Error checking drive errors: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CHECK COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: If you plugged a drive into your TV, make sure:" -ForegroundColor Yellow
Write-Host "  1. The drive is formatted in a format your TV supports (usually FAT32 or exFAT)" -ForegroundColor Yellow
Write-Host "  2. The drive is properly connected to the TV's USB port" -ForegroundColor Yellow
Write-Host "  3. Check your TV's settings/menu for USB device recognition" -ForegroundColor Yellow

