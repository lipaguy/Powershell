# Function to handle and display errors
function Handle-Error {
    param (
        [string]$Operation,
        [System.Management.Automation.ErrorRecord]$Error
    )
    Write-Host "Failed to $Operation with the following error: $($Error.Exception.Message)" -ForegroundColor Red
    Write-Host "Suggestion: Please ensure you are running PowerShell as an Administrator." -ForegroundColor Yellow
}

# Re-enable Real-Time Protection via Registry
function Enable-RealTimeProtection-Registry {
    try {
        # Re-enable Windows Defender AntiSpyware
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 0 -Force
        Write-Host "Windows Defender AntiSpyware Re-enabled Successfully via Registry" -ForegroundColor Green

        # Re-enable Real-Time Monitoring
        $realTimePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
        if (-not (Test-Path $realTimePath)) {
            New-Item -Path $realTimePath -Force
        }
        Set-ItemProperty -Path $realTimePath -Name "DisableRealtimeMonitoring" -Value 0 -Force
        Write-Host "Real-Time Protection Re-enabled Successfully via Registry" -ForegroundColor Green

    } catch {
        Handle-Error "re-enable Real-Time Protection via Registry" $_
    }
}

# Attempt to Re-enable Real-Time Protection via PowerShell
function Enable-RealTimeProtection-PowerShell {
    try {
        Set-MpPreference -DisableRealtimeMonitoring $false
        Write-Host "Real-Time Protection Re-enabled Successfully via PowerShell" -ForegroundColor Green
    } catch {
        Handle-Error "re-enable Real-Time Protection via PowerShell" $_
    }
}

# Re-enable Real-Time Protection using all methods
Enable-RealTimeProtection-Registry
Enable-RealTimeProtection-PowerShell

# Re-enable Cloud-Delivered Protection
try {
    Set-MpPreference -MAPSReporting 2
    Write-Host "Cloud-Delivered Protection Re-enabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "re-enable Cloud-Delivered Protection" $_
}

# Re-enable Automatic Sample Submission
try {
    Set-MpPreference -SubmitSamplesConsent 1
    Write-Host "Automatic Sample Submission Re-enabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "re-enable Automatic Sample Submission" $_
}

# Re-enable Behavior Monitoring
try {
    Set-MpPreference -DisableBehaviorMonitoring $false
    Write-Host "Behavior Monitoring Re-enabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "re-enable Behavior Monitoring" $_
}

# Re-enable IOAV Protection
try {
    Set-MpPreference -DisableIOAVProtection $false
    Write-Host "IOAV Protection Re-enabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "re-enable IOAV Protection" $_
}

# Re-enable Script Scanning
try {
    Set-MpPreference -DisableScriptScanning $false
    Write-Host "Script Scanning Re-enabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "re-enable Script Scanning" $_
}

# Re-enable Windows Defender Firewall
try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Write-Host "Windows Defender Firewall Re-enabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "re-enable Windows Defender Firewall" $_
}

# Display Current Status of Windows Defender Settings
try {
    $DefenderStatus = Get-MpPreference
    $FirewallStatus = Get-NetFirewallProfile

    Write-Host "`nWindows Defender Status:"
    Write-Host "Real-Time Protection Enabled: " -ForegroundColor Green $DefenderStatus.DisableRealtimeMonitoring -eq $false
    Write-Host "Cloud-Delivered Protection Enabled: " -ForegroundColor Green $DefenderStatus.MAPSReporting -eq 2
    Write-Host "Automatic Sample Submission Enabled: " -ForegroundColor Green $DefenderStatus.SubmitSamplesConsent -eq 1
    Write-Host "Behavior Monitoring Enabled: " -ForegroundColor Green $DefenderStatus.DisableBehaviorMonitoring -eq $false
    Write-Host "IOAV Protection Enabled: " -ForegroundColor Green $DefenderStatus.DisableIOAVProtection -eq $false
    Write-Host "Script Scanning Enabled: " -ForegroundColor Green $DefenderStatus.DisableScriptScanning -eq $false

    Write-Host "`nWindows Defender Firewall Status:"
    $FirewallStatus | ForEach-Object {
        Write-Host $_.Name ": " -ForegroundColor Green $_.Enabled
    }
} catch {
    Handle-Error "retrieve Windows Defender or Firewall status" $_
}

Write-Host "`nScript execution completed."
