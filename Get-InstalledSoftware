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

# Variables for PSThreadJob checking
$modPSThreadJob = "PSThreadJob"
$chkPSThreadJob = Get-Module -Name $modPSThreadJob

# Check if PSThreadJob module is installed and if not install the current version
if (-not $chkPSThreadJob) {
    Install-Module -Name $modPSThreadJob
}

# Import PSThreadJob module
Import-Module -Name $modPSThreadJob

Write-InfoLog "PSThreadJob module imported"

function Get-InstalledSoftware {
    <#
    .SYNOPSIS
        Retrieves a list of all software installed
    .DESCRIPTION
        This function scans the registry to find the GUID of software installed on the computer.
    .EXAMPLE
        Get-InstalledSoftware

        This example retrieves all software installed on the local computer
    .PARAMETER Name
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
        [string]$Name
    )
    $uninstallKeys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS
    $uninstallKeys += Get-ChildItem HKU: -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | ForEach-Object -Parallel -ThrottleLimit 8 { "HKU:\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall" }

    if (-not $uninstallKeys) {
        Write-InfoLog -Message 'No software registry keys found'
    } else {
        $results = $uninstallKeys | ForEach-Object -Parallel -ThrottleLimit 8 {
            $uninstallKey = $_
            if ($Using:Name) {
                $whereBlock = { ($_.PSChildName -match '^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$') -and ($_.GetValue('DisplayName') -like "$Using:Name*") }
            } else {
                $whereBlock = { ($_.PSChildName -match '^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$') -and ($_.GetValue('DisplayName')) }
            }
            $gciParams = @{
                Path        = $uninstallKey
                ErrorAction = 'SilentlyContinue'
            }
            $selectProperties = @(
                @{n='GUID'; e={$_.PSChildName}},
                @{n='Name'; e={$_.GetValue('DisplayName')}}
            )
            Get-ChildItem @gciParams | Where-Object $whereBlock | Select-Object -Property $selectProperties
        }

        Write-InfoLog "Get-InstalledSoftware - List of software found:"
        $results | ForEach-Object -Parallel -ThrottleLimit 8 {
            Write-InfoLog "Name: $($_.Name) - GUID: $($_.GUID)"
        }

        return $results
    }
}
