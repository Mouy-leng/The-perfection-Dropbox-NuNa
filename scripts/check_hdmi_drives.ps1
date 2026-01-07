Write-Host "=== HDMI Monitor Status ===" -ForegroundColor Cyan
Get-PnpDevice -Class Monitor | Where-Object {$_.FriendlyName -like '*HDMI*' -or $_.Status -eq 'OK'} | Select-Object FriendlyName, Status | Format-Table -AutoSize

Write-Host "`n=== Currently Connected Drives ===" -ForegroundColor Cyan
$drives = Get-Volume | Where-Object {$_.DriveLetter -ne $null}
foreach($d in $drives) {
    $sizeGB = [math]::Round($d.Size/1GB, 2)
    $freeGB = [math]::Round($d.SizeRemaining/1GB, 2)
    Write-Host "Drive $($d.DriveLetter):" -ForegroundColor Green
    Write-Host "  Type: $($d.DriveType)"
    Write-Host "  Label: $($d.FileSystemLabel)"
    Write-Host "  Size: $sizeGB GB"
    Write-Host "  Free: $freeGB GB"
    Write-Host "  Health: $($d.HealthStatus)"
    Write-Host ""
}

Write-Host "=== Physical Disks ===" -ForegroundColor Cyan
Get-Disk | Select-Object Number, FriendlyName, @{Name='Size(GB)';Expression={[math]::Round($_.Size/1GB,2)}}, BusType, OperationalStatus | Format-Table -AutoSize

Write-Host "=== Removable/USB Drives ===" -ForegroundColor Cyan
$removable = Get-Volume | Where-Object {$_.DriveType -eq 'Removable'}
if ($removable) {
    foreach($r in $removable) {
        Write-Host "Removable Drive: $($r.DriveLetter): - $($r.FileSystemLabel)" -ForegroundColor Yellow
    }
} else {
    Write-Host "No removable/USB drives detected on this computer" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "NOTE: If you plugged a USB drive into your TV/Monitor:" -ForegroundColor Yellow
    Write-Host "  - The drive will NOT appear on your computer" -ForegroundColor Yellow
    Write-Host "  - You can only access it through your TV's interface" -ForegroundColor Yellow
    Write-Host "  - To access it from your computer, you need to:" -ForegroundColor Yellow
    Write-Host "    1. Plug the drive directly into your computer's USB port, OR" -ForegroundColor Yellow
    Write-Host "    2. Use your TV's network sharing feature (if available)" -ForegroundColor Yellow
}
