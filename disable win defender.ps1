# Function to handle and display errors
function Handle-Error {
    param (
        [string]$Operation,
        [System.Management.Automation.ErrorRecord]$Error
    )
    Write-Host "Failed to $Operation with the following error: $($Error.Exception.Message)" -ForegroundColor Red
    Write-Host "Suggestion: Please ensure you are running PowerShell as an Administrator." -ForegroundColor Yellow
}

# Disable Tamper Protection
function Disable-TamperProtection {
    try {
        Set-MpPreference -DisableTamperProtection $true
        Write-Host "Tamper Protection Disabled Successfully" -ForegroundColor Green
    } catch {
        Handle-Error "disable Tamper Protection" $_
    }
}

# Disable Real-Time Protection via Registry
function Disable-RealTimeProtection-Registry {
    try {
        # Disable Windows Defender AntiSpyware
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Force
        Write-Host "Windows Defender AntiSpyware Disabled Successfully via Registry" -ForegroundColor Green

        # Disable Real-Time Monitoring
        $realTimePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
        if (-not (Test-Path $realTimePath)) {
            New-Item -Path $realTimePath -Force
        }
        Set-ItemProperty -Path $realTimePath -Name "DisableRealtimeMonitoring" -Value 1 -Force
        Write-Host "Real-Time Protection Disabled Successfully via Registry" -ForegroundColor Green

    } catch {
        Handle-Error "disable Real-Time Protection via Registry" $_
    }
}

# Attempt to Disable Real-Time Protection via PowerShell
function Disable-RealTimeProtection-PowerShell {
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true
        Write-Host "Real-Time Protection Disabled Successfully via PowerShell" -ForegroundColor Green
    } catch {
        Handle-Error "disable Real-Time Protection via PowerShell" $_
    }
}

# Disable Real-Time Protection using all methods
Disable-TamperProtection
Disable-RealTimeProtection-Registry
Disable-RealTimeProtection-PowerShell

# Disable other Windows Defender Features
try {
    Set-MpPreference -MAPSReporting 0
    Write-Host "Cloud-Delivered Protection Disabled Successfully" -ForegroundColor Green

    Set-MpPreference -SubmitSamplesConsent 2
    Write-Host "Automatic Sample Submission Disabled Successfully" -ForegroundColor Green

    Set-MpPreference -DisableBehaviorMonitoring $true
    Write-Host "Behavior Monitoring Disabled Successfully" -ForegroundColor Green

    Set-MpPreference -DisableIOAVProtection $true
    Write-Host "IOAV Protection Disabled Successfully" -ForegroundColor Green

    Set-MpPreference -DisableScriptScanning $true
    Write-Host "Script Scanning Disabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "disable other Windows Defender features" $_
}

# Disable Windows Defender Firewall
try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    Write-Host "Windows Defender Firewall Disabled Successfully" -ForegroundColor Green
} catch {
    Handle-Error "disable Windows Defender Firewall" $_
}

# Display Current Status of Windows Defender Settings
try {
    $DefenderStatus = Get-MpPreference
    $FirewallStatus = Get-NetFirewallProfile

    Write-Host "`nWindows Defender Status:"
    Write-Host "Real-Time Protection Disabled: " $DefenderStatus.DisableRealtimeMonitoring
    Write-Host "Cloud-Delivered Protection Disabled: " $DefenderStatus.MAPSReporting
    Write-Host "Automatic Sample Submission Disabled: " $DefenderStatus.SubmitSamplesConsent
    Write-Host "Behavior Monitoring Disabled: " $DefenderStatus.DisableBehaviorMonitoring
    Write-Host "IOAV Protection Disabled: " $DefenderStatus.DisableIOAVProtection
    Write-Host "Script Scanning Disabled: " $DefenderStatus.DisableScriptScanning

    Write-Host "`nWindows Defender Firewall Status:"
    $FirewallStatus | ForEach-Object {
        Write-Host $_.Name ": " $_.Enabled
    }
} catch {
    Handle-Error "retrieve Windows Defender or Firewall status" $_
}

Write-Host "`nScript execution completed."
