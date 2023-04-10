<#
.SYNOPSIS
    Deletes user profiles on a computer, excluding specified accounts.

.DESCRIPTION
    This script deletes all user profiles on a computer except those listed in the $acctsExcluded variable. 
    It checks if the WinRM service is running and configures it if necessary.

.EXAMPLE
    .\Remove-UserProfiles.ps1

.NOTES
    Version: 1.1.2
    Author: Fred Smith
    Creation Date: 04/10/2023

    acctsExcluded:
    An array of account names (usernames or SIDs) that should be excluded from the removal process. This includes ramadmin and built-in accounts.

    Invoke-WinRM:
    A function that will check if the WinRM service is running and if it is not, it will configure and start the service. This service is required for the script to work.

    Additional notes:
    Make sure you run the script in an elevated PowerShell session.
#>

# Function to check if WinRM service is running and configured
function Invoke-WinRM {
    $winrmService = Get-Service -Name WinRM
    $winrmCommand = cmd.exe /c $WinRM quickconfig
    if ($winrmService.Status -ne "Running") {
        Write-Host "WinRM service is not running. Configuring..."
        try {
            $winrmCommand
            Write-Host "WinRM has been configured successfully."
        } catch {
            Write-Error "An error occurred while configuring WinRM: $_"
        }
    } else {
        Write-Host "WinRM service is running."
    }
}

Invoke-WinRM

# Variables that create an array of the accounts to be excluded from removal process
$acctsExcluded = @("ramadmin", "S-1-5-18", "S-1-5-19", "S-1-5-20")

# Method that will delete all of the user profiles on a computer, except the accounts listed in the $acctsExcluded variable
Get-CimInstance -Class Win32_UserProfile | Where-Object { ($_.LocalPath -ne $null) -and ($_.LocalPath.split('\')[-1] -notin $acctsExcluded) -and ($_.SID -notin $acctsExcluded) } | Remove-CimInstance
