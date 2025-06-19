<#
.SYNOPSIS
    Checks chassis type and Secure Boot status, and runs the appropriate BIOS configuration executable if Secure Boot is off.

.DESCRIPTION
    Determines if the system is a laptop or desktop and whether Secure Boot is enabled.
    If Secure Boot is off, runs the appropriate BIOS configuration executable for the chassis type.
    Logs all actions using PoShLog.

.NOTES
    Requires: PowerShell 5.1+, PoShLog module
    Author: Adapted by GitHub Copilot

.EXAMPLE
    .\Edit-BIOSConfig.ps1
#>

[CmdletBinding()]
param (
    [string]$logDirectory = "$env:SystemDrive\Logs",
    [string]$logFileName = 'Edit-BIOSConfig.log'
)

function Import-RequiredModule {
    param (
        [string]$moduleName
    )
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Install-Module -Name $moduleName -Force -Scope CurrentUser
    }
    Import-Module -Name $moduleName -Force
}

function Install-NugetProvider {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name 'NuGet' -Force
    }
}

function Set-PsGalleryTrusted {
    $psGallery = Get-PSRepository -Name PSGallery
    if ($psGallery.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
}

function Get-ChassisType {
    <#
    .SYNOPSIS
        Returns 'Laptop' or 'Desktop' based on chassis type.
    .NOTES
        Chassis types: 9 (Laptop), 10 (Notebook), 14 (SubNotebook)
    #>
    $laptopTypes = @(9, 10, 14)
    try {
        $chassis = Get-CimInstance -ClassName Win32_SystemEnclosure
        if ($chassis.ChassisTypes | Where-Object { $laptopTypes -contains $_ }) {
            return 'Laptop'
        } else {
            return 'Desktop'
        }
    } catch {
        Write-ErrorLog "Unable to determine chassis type: $_"
        return $null
    }
}

function Test-SecureBootEnabled {
    <#
    .SYNOPSIS
        Checks if Secure Boot is enabled.
    #>
    $secureBootRegKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State'
    try {
        $value = Get-ItemPropertyValue -Path $secureBootRegKey -Name UEFISecureBootEnabled -ErrorAction Stop
        return ($value -eq 1)
    } catch {
        Write-ErrorLog "Unable to read Secure Boot status: $_"
        return $false
    }
}

# --- Main Script ---

# Ensure script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error 'Script must be run as an administrator.'
    exit 1
}

Install-NugetProvider
Set-PsGalleryTrusted
Import-RequiredModule -moduleName 'PoShLog'

# Prepare logging
$logFilePath = Join-Path $logDirectory $logFileName
$logger = New-Logger
$logger | Set-MinimumLevel -Value Information | Add-SinkFile -Path $logFilePath | Add-SinkConsole | Start-Logger

Write-InfoLog 'Logger initialized'

try {
    $pathLaptopBiosExe = "$env:systemDrive\Tanium_Software\BIOSConf-Laptop_x64"
    $pathDesktopBiosExe = "$env:systemDrive\Tanium_Software\BIOSConf-Desktop_x64"

    $chassisType = Get-ChassisType
    $secureBootEnabled = Test-SecureBootEnabled

    Write-InfoLog "This machine is a $chassisType."
    if ($secureBootEnabled) {
        Write-InfoLog 'BIOS Configuration: Secure boot is on.'
    } else {
        Write-InfoLog 'BIOS Configuration: Secure boot is off.'
    }

    if ($chassisType -eq 'Laptop' -and -not $secureBootEnabled) {
        Write-InfoLog "Running: $pathLaptopBiosExe"
        Start-Process -FilePath $pathLaptopBiosExe -Wait
    } elseif ($chassisType -eq 'Desktop' -and -not $secureBootEnabled) {
        Write-InfoLog "Running: $pathDesktopBiosExe"
        Start-Process -FilePath $pathDesktopBiosExe -Wait
    } else {
        Write-InfoLog 'No BIOS configuration change required.'
    }
}
catch {
    Write-ErrorLog "Error during BIOS configuration: $($_.Exception.Message)"
    exit 1
}
finally {
    Close-Logger
}
