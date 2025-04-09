# Update-TPMKeys2.ps1

<#
.SYNOPSIS
    This script is useful for fixing errors between BitLocker and SecureBoot; particularly, if BitLocker gets activated while SecureBoot is disabled. This can cause issues with functions that need to disable BitLocker, like BIOS updates, causing the system to prompt for a BitLocker key.

.DESCRIPTION
    This script will:
    1. Delete the BitLocker key protector on the system drive
    2. Establish 7,11 as the key protector, which is the correct protector for BitLocker working in conjunction with SecureBoot
    3. Log everything to a log file using PoShLog

.NOTES
    File Name      : Repair-Printing.ps1
    Author         : Fred Smith III
    Prerequisite   : PowerShell V2
    Copyright 2023: Valhalla Tech

    Additional notes:
    Make sure SecureBoot is enabled when running this script or it will revert back to incorrect key protectors.
    Edit-BIOSConfig.ps1 is a part of this repository and will enable SecureBoot without having to boot into UEFI settings.

.EXAMPLE
    This example shows how to run the script:
    .\ClearPrintQueue.ps1
#>

# Check if PoShLog module is installed and if not install the current version
$modPoShLog = "PoShLog"
$chkPoShLog = Get-InstalledModule -Name $modPoShLog -ErrorAction SilentlyContinue

# Install Nuget Provider, if not already installed
Install-PackageProvider -Name "NuGet" -Force

# Set PSGallery as a trusted repository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if (-not $chkPoShLog) {
    Install-Module -Name $modPoShLog
}

# Import PoShLog module
Import-Module -Name $modPoShLog

# Configure variables for logging
$systemDrive = $env:SystemDrive
$logFileName = "Update-TPMKeys.log"
$logFilePath = "$systemDrive\Logs\$logFileName"

# Create logger instance
$logger = New-Logger

# Configure logger instance
$logger |
    Set-MinimumLevel -Value Information |
    Add-SinkFile -Path $logFilePath |
    Add-SinkConsole |
    Start-Logger

Write-InfoLog "PoShLog module imported and logger configured"

try {
    # Get the BitLocker volume for the operating system partition and find the ID of the TPM key protector
    $volume = Get-WMIObject -Namespace "root/CIMV2/Security/MicrosoftVolumeEncryption" -Class 'Win32_EncryptableVolume' -Filter "DriveLetter='C:'"
    $tpmProtectorID = $volume.getkeyprotectors().VolumeKeyProtectorID | Where-Object {$volume.getkeyprotectortype($_).keyprotectortype -eq 1}

    # Delete the TPM key protector
    $volume.DeleteKeyProtector($TPMprotectorID) | Out-Null
    $volume.getkeyprotectors().VolumeKeyProtectorID | Where-Object {$volume.getkeyprotectortype($_).keyprotectortype -eq 1}

    # Add the TPM key protector with settings specified, as a parameter, for Secure Boot
    $volume.ProtectKeyWithTPM("ProtectWithTPM1", (7,11))

    # Displays active PCR values and verifies that the script was successful
    manage-bde.exe -protectors -get $systemDrive

    # Log a success message
    Write-InfoLog "BitLocker TPM key protector was successfully added."
}
catch {
    # Log the error message and write it to the console
    Write-ErrorLog "Error adding BitLocker TPM key protector: $_"
}
finally {
    Close-Logger
}
