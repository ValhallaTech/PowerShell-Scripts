# Variables for PoShLog checking
$modPoShLog = "PoShLog"
$chkPoShLog = Get-Module -Name $modPoShLog

# Check if PoShLog module is installed and if not install the current version
if (-not $chkPoShLog) {
    Install-Module -Name $modPoShLog
}

# Import PoShLog module
Import-Module -Name $modPoShLog

# Configure variables for logging
$logFileName = "Get-InstalledSoftware.log"
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

# Variables for PSParallel checking
$modPSParallel = "PSParallel"
$chkPSParallel = Get-Module -Name $modPSParallel

# Check if PSParallel module is installed and if not install the current version
if (-not $chkPSParallel) {
    try {
        Install-Module -Name $modPSParallel -ErrorAction Stop
    } catch {
        Write-ErrorLog "Failed to install PSParallel module: $_"
        exit 1
    }
}

# Import PSParallel module
try {
    Import-Module -Name $modPSParallel -ErrorAction Stop
} catch {
    Write-ErrorLog "Failed to import PSParallel module: $_"
    exit 1
}

Write-InfoLog "PSParallel module imported"
function Get-InstalledSoftware {
    <#
    .SYNOPSIS
        Retrieves a list of all software installed
    .DESCRIPTION
        This function scans the registry to find the GUID of software installed on the computer.
    .EXAMPLE
        Get-InstalledSoftware

        This example retrieves all software installed on the local computer
    .PARAMETER name
        The software title you'd like to limit the query to.
    .AUTHOR
        Fred Smith III
    .VERSION
        1.0.0
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$name
    )
    $uninstallKeys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS
    $uninstallKeys += Get-ChildItem HKU: -ErrorAction SilentlyContinue | Where-Object { $_.name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | ForEach-Object { "HKU:\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall" }

    if (-not $uninstallKeys) {
        Write-InfoLog -Message 'No software registry keys found'
    } else {
        $results = $uninstallKeys | Invoke-Parallel -ThrottleLimit 16 -ScriptBlock {
            #param($name)
            $uninstallKey = $_
            $name = $args[0]
            if ($name) {
                $whereBlock = { ($_.PSChildName -match '^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$') -and ($_.GetValue('DisplayName') -like "$name*") }
            } else {
                $whereBlock = { ($_.PSChildName -match '^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$') -and ($_.GetValue('DisplayName')) }
            }
            $gciParams = @{
                Path        = $uninstallKey
                ErrorAction = 'SilentlyContinue'
            }
            $selectProperties = @(
                @{n='GUID'; e={$_.PSChildName}},
                @{n='name'; e={$_.GetValue('DisplayName')}}
            )
            Get-ChildItem @gciParams | Where-Object $whereBlock | Select-Object -Property $selectProperties
        }

        Write-InfoLog "Get-InstalledSoftware - List of software found:"
        $results | ForEach-Object {
            Write-InfoLog "Name: $($_.Name) - GUID: $($_.GUID)"
        }

        return $results
        Close-Logger
    }
}

Get-InstalledSoftware
