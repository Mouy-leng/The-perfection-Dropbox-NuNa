$outputFile = "hdmi_status_report.txt"
"========================================" | Out-File -FilePath $outputFile -Encoding UTF8
"   COMPREHENSIVE HDMI CHECK" | Out-File -FilePath $outputFile -Append -Encoding UTF8
"========================================" | Out-File -FilePath $outputFile -Append -Encoding UTF8
"" | Out-File -FilePath $outputFile -Append -Encoding UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   COMPREHENSIVE HDMI CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check all monitors/displays
Write-Host "--- CONNECTED DISPLAYS ---" -ForegroundColor Yellow
try {
    $monitors = Get-PnpDevice -Class Monitor
    if ($monitors) {
        foreach ($monitor in $monitors) {
            $statusColor = if ($monitor.Status -eq "OK") { "Green" } else { "Red" }
            Write-Host "Monitor: $($monitor.FriendlyName)" -ForegroundColor Green
            Write-Host "  Status: $($monitor.Status)" -ForegroundColor $statusColor
            Write-Host "  Instance ID: $($monitor.InstanceId)"
            Write-Host ""
        }
    } else {
        Write-Host "No monitors found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error checking monitors: $_" -ForegroundColor Red
}

# Check display configuration
Write-Host "--- DISPLAY CONFIGURATION ---" -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $screenNum = 1
    foreach ($screen in $screens) {
        Write-Host "Display $screenNum : $($screen.DeviceName)" -ForegroundColor Green
        Write-Host "  Resolution: $($screen.Bounds.Width)x$($screen.Bounds.Height)"
        Write-Host "  Primary: $($screen.Primary)"
        Write-Host "  Working Area: $($screen.WorkingArea.Width)x$($screen.WorkingArea.Height)"
        Write-Host ""
        $screenNum++
    }
} catch {
    Write-Host "Error checking display configuration: $_" -ForegroundColor Red
}

# Check for HDMI-specific devices
Write-Host "--- HDMI DEVICES ---" -ForegroundColor Yellow
try {
    $hdmiDevices = Get-PnpDevice | Where-Object {
        $_.FriendlyName -like '*HDMI*' -or 
        $_.FriendlyName -like '*Display*' -or
        $_.InstanceId -like '*HDMI*'
    }
    if ($hdmiDevices) {
        foreach ($device in $hdmiDevices) {
            Write-Host "Device: $($device.FriendlyName)" -ForegroundColor Green
            Write-Host "  Class: $($device.Class)"
            Write-Host "  Status: $($device.Status)"
            Write-Host ""
        }
    } else {
        Write-Host "No HDMI-specific devices found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error checking HDMI devices: $_" -ForegroundColor Red
}

# Check graphics adapters
Write-Host "--- GRAPHICS ADAPTERS ---" -ForegroundColor Yellow
try {
    $adapters = Get-WmiObject Win32_VideoController
    foreach ($adapter in $adapters) {
        Write-Host "Adapter: $($adapter.Name)" -ForegroundColor Green
        Write-Host "  Status: $($adapter.Status)"
        Write-Host "  Current Resolution: $($adapter.CurrentHorizontalResolution)x$($adapter.CurrentVerticalResolution)"
        Write-Host "  Driver Version: $($adapter.DriverVersion)"
        Write-Host ""
    }
} catch {
    Write-Host "Error checking graphics adapters: $_" -ForegroundColor Red
}

# Check connected drives
Write-Host "--- CONNECTED DRIVES ---" -ForegroundColor Yellow
try {
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
} catch {
    Write-Host "Error checking drives: $_" -ForegroundColor Red
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CHECK COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
