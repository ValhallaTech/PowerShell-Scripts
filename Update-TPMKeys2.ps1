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
