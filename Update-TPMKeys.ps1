# General Variables
$systemDrive = $env:SystemDrive

# Get the BitLocker volume for the operating system partition and find the ID of the TPM key protector
$volume = Get-WMIObject -Namespace "root/CIMV2/Security/MicrosoftVolumeEncryption" -Class 'Win32_EncryptableVolume' -Filter "DriveLetter='C:'"
$tpmProtectorID = $volume.getkeyprotectors().VolumeKeyProtectorID | Where-Object {$volume.getkeyprotectortype($_).keyprotectortype -eq 1}

# Delete the TPM key protector
$volume.DeleteKeyProtector($TPMprotectorID) | out-null
$volume.getkeyprotectors().VolumeKeyProtectorID | Where-Object {$volume.getkeyprotectortype($_).keyprotectortype -eq 1}

# Add the TPM key protector with settings specified, as a parameter, for Secure Boot
$volume.ProtectKeyWithTPM("ProtectWithTPM1", (7,11))

#Displays avtive PCR values and verfies that the script was successful
manage-bde.exe -protectors -get $systemDrive




# Import the PoShLog module
Import-Module PoShLog

# Set up logging configuration
$logFile = "$env:SystemDrive\Temp\BitLocker.log"
$logConfig = New-LogConfig -LogFilePath $logFile -MinimumLogLevel Info
Set-LogConfig $logConfig

# General Variables
$systemDrive = $env:SystemDrive

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
    Write-Log -Message "BitLocker TPM key protector was successfully added." -LogLevel Info
}
catch {
    # Log the error message and write it to the console
    Write-Log -Message "Error adding BitLocker TPM key protector: $_" -LogLevel Error
    Write-Error $_
}
finally {
    # Save the log file
    Save-LogFile
}
