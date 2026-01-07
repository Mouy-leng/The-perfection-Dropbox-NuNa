# Comprehensive System Report
# Combines system info and drive health check

$report = @()

function Add-Report {
    param([string]$text)
    $script:report += $text
    Write-Output $text
}

Add-Report "========================================"
Add-Report "   COMPREHENSIVE SYSTEM REPORT"
Add-Report "   Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Report "========================================"
Add-Report ""

# System Information
Add-Report "--- SYSTEM INFORMATION ---"
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem
    
    Add-Report "OS Name: $($os.Caption)"
    Add-Report "OS Version: $($os.Version)"
    Add-Report "Computer Name: $($computer.Name)"
    Add-Report "Manufacturer: $($computer.Manufacturer)"
    Add-Report "Model: $($computer.Model)"
    Add-Report ""
} catch {
    Add-Report "Error retrieving system info: $_"
}

# Video Controllers
Add-Report "--- VIDEO CONTROLLERS ---"
try {
    $videoControllers = Get-CimInstance Win32_VideoController
    foreach ($vc in $videoControllers) {
        Add-Report "Name: $($vc.Name)"
        Add-Report "  Status: $($vc.Status)"
        Add-Report "  Video Mode: $($vc.VideoModeDescription)"
        Add-Report "  Adapter RAM: $([math]::Round($vc.AdapterRAM / 1GB, 2)) GB"
        Add-Report ""
    }
} catch {
    Add-Report "Error retrieving video controller info: $_"
}

# Monitor Connections
Add-Report "--- MONITOR CONNECTIONS ---"
try {
    $monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams
    if ($monitors) {
        foreach ($monitor in $monitors) {
            $tech = switch ($monitor.VideoOutputTechnology) {
                0 { "Uninitialized" }
                1 { "Other" }
                2 { "HDMI" }
                3 { "SDI" }
                4 { "DisplayPort" }
                5 { "HDMI" }
                2147483648 { "DisplayPort/HDMI" }
                default { "Unknown ($($monitor.VideoOutputTechnology))" }
            }
            Add-Report "Monitor: $($monitor.InstanceName)"
            Add-Report "  Connection Type: $tech"
            Add-Report "  Active: $($monitor.Active)"
            Add-Report ""
        }
    } else {
        Add-Report "No monitor connection information found"
    }
} catch {
    Add-Report "Error retrieving monitor info: $_"
}

# Drive Status
Add-Report "--- DRIVE STATUS ---"
try {
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }
    if ($volumes) {
        foreach ($vol in $volumes) {
            $sizeGB = [math]::Round($vol.Size / 1GB, 2)
            $freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)
            $usedGB = [math]::Round(($vol.Size - $vol.SizeRemaining) / 1GB, 2)
            $percentFree = [math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 1)
            
            Add-Report "Drive: $($vol.DriveLetter):"
            Add-Report "  Label: $($vol.FileSystemLabel)"
            Add-Report "  File System: $($vol.FileSystemType)"
            Add-Report "  Total Size: $sizeGB GB"
            Add-Report "  Used: $usedGB GB"
            Add-Report "  Free: $freeGB GB ($percentFree%)"
            Add-Report "  Health Status: $($vol.HealthStatus)"
            Add-Report "  Operational Status: $($vol.OperationalStatus)"
            Add-Report ""
        }
    } else {
        Add-Report "No drives found"
    }
} catch {
    Add-Report "Error retrieving drive info: $_"
}

# Physical Disks
Add-Report "--- PHYSICAL DISKS ---"
try {
    $disks = Get-Disk
    if ($disks) {
        foreach ($disk in $disks) {
            $sizeGB = [math]::Round($disk.Size / 1GB, 2)
            Add-Report "Disk $($disk.Number): $($disk.FriendlyName)"
            Add-Report "  Size: $sizeGB GB"
            Add-Report "  Partition Style: $($disk.PartitionStyle)"
            Add-Report "  Health Status: $($disk.HealthStatus)"
            Add-Report "  Operational Status: $($disk.OperationalStatus)"
            Add-Report "  Bus Type: $($disk.BusType)"
            Add-Report ""
        }
    } else {
        Add-Report "No physical disks found"
    }
} catch {
    Add-Report "Error retrieving disk info: $_"
}

# Screen Information
Add-Report "--- SCREEN INFORMATION ---"
try {
    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    foreach ($screen in $screens) {
        Add-Report "Screen: $($screen.DeviceName)"
        Add-Report "  Bounds: $($screen.Bounds)"
        Add-Report "  Working Area: $($screen.WorkingArea)"
        Add-Report "  Primary: $($screen.Primary)"
        Add-Report ""
    }
} catch {
    Add-Report "Error retrieving screen info: $_"
}

Add-Report "========================================"
Add-Report "   REPORT COMPLETE"
Add-Report "========================================"

# Save to file
$outputFile = Join-Path $PSScriptRoot "full_system_report.txt"
$report | Out-File -FilePath $outputFile -Encoding UTF8
Write-Output ""
Write-Output "Report saved to: $outputFile"



