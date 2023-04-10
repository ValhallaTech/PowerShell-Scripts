# User Profile Sweeper 1.0.2

# Function to check if WinRM service is running and configured
function Invoke-WinRM {
    $winrmService = Get-Service -Name WinRM
    $winrmCommand = cmd.exe /c "$WinRM quickconfig -quiet"
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

# Variables that create an array of the accounts to be excluded from removal process
$acctsExcluded = @("ramadmin", "S-1-5-18", "S-1-5-19", "S-1-5-20")

# Method that will delete all of the user profiles on a computer, except the accounts listed in the $acctsExcluded variable
Get-CimInstance -Class Win32_UserProfile | Where-Object { ($_.LocalPath -ne $null) -and ($_.LocalPath.split('\')[-1] -notin $acctsExcluded) -and ($_.SID -notin $acctsExcluded) } | Remove-CimInstance
