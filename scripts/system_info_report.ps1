# System Information Report Script
# This script provides comprehensive system information including HDMI/Display status
# Outputs to both console and file for reliable reporting

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptPath) { $scriptPath = $PWD.Path }
$outputFile = Join-Path $scriptPath "system_info_output.txt"
$output = @()

function Add-Output {
    param([string]$text, [string]$color = "White")
    $output += $text
    # Check if running in a console that supports colors
    $hostSupportsColors = $Host.UI.RawUI.ForegroundColor -ne $null
    if ($hostSupportsColors) {
        try {
            Write-Host $text -ForegroundColor $color
        } catch {
            Write-Output $text
        }
    } else {
        Write-Output $text
    }
}

Add-Output "========================================" "Cyan"
Add-Output "   SYSTEM INFORMATION REPORT" "Cyan"
Add-Output "========================================" "Cyan"
Add-Output ""

# Video Controllers
Add-Output "--- VIDEO CONTROLLERS ---" "Yellow"
try {
    $videoControllers = Get-CimInstance Win32_VideoController
    foreach ($vc in $videoControllers) {
        Add-Output "Name: $($vc.Name)" "Green"
        Add-Output "  Status: $($vc.Status)"
        Add-Output "  Video Mode: $($vc.VideoModeDescription)"
        Add-Output "  Adapter RAM: $([math]::Round($vc.AdapterRAM / 1GB, 2)) GB"
        Add-Output ""
    }
} catch {
    Add-Output "Error retrieving video controller info: $_" "Red"
}

# Monitor Connections
Add-Output "--- MONITOR CONNECTIONS ---" "Yellow"
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
            Add-Output "Monitor: $($monitor.InstanceName)" "Green"
            Add-Output "  Connection Type: $tech"
            Add-Output "  Active: $($monitor.Active)"
            Add-Output ""
        }
    } else {
        Add-Output "No monitor connection information found" "Yellow"
    }
} catch {
    Add-Output "Error retrieving monitor info: $_" "Red"
}

# Desktop Monitors
Add-Output "--- DESKTOP MONITORS ---" "Yellow"
try {
    $desktopMonitors = Get-CimInstance Win32_DesktopMonitor
    if ($desktopMonitors) {
        foreach ($dm in $desktopMonitors) {
            Add-Output "Name: $($dm.Name)" "Green"
            Add-Output "  Status: $($dm.Status)"
            Add-Output "  Availability: $($dm.Availability)"
            Add-Output ""
        }
    } else {
        Add-Output "No desktop monitor information found" "Yellow"
    }
} catch {
    Add-Output "Error retrieving desktop monitor info: $_" "Red"
}

# PnP Devices (HDMI related)
Add-Output "--- HDMI/Display PnP Devices ---" "Yellow"
try {
    $hdmiDevices = Get-PnpDevice | Where-Object { 
        $_.FriendlyName -like '*HDMI*' -or 
        $_.FriendlyName -like '*Display*' -or 
        $_.Class -eq 'Monitor' 
    }
    if ($hdmiDevices) {
        foreach ($device in $hdmiDevices) {
            Add-Output "Device: $($device.FriendlyName)" "Green"
            Add-Output "  Status: $($device.Status)"
            Add-Output "  Class: $($device.Class)"
            Add-Output ""
        }
    } else {
        Add-Output "No HDMI/Display PnP devices found" "Yellow"
    }
} catch {
    Add-Output "Error retrieving PnP device info: $_" "Red"
}

# Screen Information
Add-Output "--- SCREEN INFORMATION ---" "Yellow"
try {
    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    foreach ($screen in $screens) {
        Add-Output "Screen: $($screen.DeviceName)" "Green"
        Add-Output "  Bounds: $($screen.Bounds)"
        Add-Output "  Working Area: $($screen.WorkingArea)"
        Add-Output "  Primary: $($screen.Primary)"
        Add-Output ""
    }
} catch {
    Add-Output "Error retrieving screen info: $_" "Red"
}

# System Summary
Add-Output "--- SYSTEM SUMMARY ---" "Yellow"
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem
    
    Add-Output "OS Name: $($os.Caption)" "Green"
    Add-Output "OS Version: $($os.Version)"
    Add-Output "Computer Name: $($computer.Name)"
    Add-Output "Manufacturer: $($computer.Manufacturer)"
    Add-Output "Model: $($computer.Model)"
    Add-Output ""
} catch {
    Add-Output "Error retrieving system summary: $_" "Red"
}

Add-Output "========================================" "Cyan"
Add-Output "   REPORT COMPLETE" "Cyan"
Add-Output "========================================" "Cyan"

# Save output to file
try {
    $output | Out-File -FilePath $outputFile -Encoding UTF8 -ErrorAction Stop
    Write-Output ""
    Write-Output "Report saved to: $outputFile"
} catch {
    Write-Output "Warning: Could not save report to file: $_"
    # Fallback: save to current directory
    try {
        $output | Out-File -FilePath "system_info_output.txt" -Encoding UTF8
        Write-Output "Report saved to: system_info_output.txt"
    } catch {
        Write-Output "Error: Could not save report file"
    }
}

