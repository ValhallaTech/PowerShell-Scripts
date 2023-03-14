# User BackerUpper 4.0.0

# Get the username of the logged-on user
$usrLoggedon = Get-Process -IncludeUserName | Select-Object -Property username -Unique | Where-Object { $_ -match "WSSUMITS" }
$usrString = $usrLoggedon.UserName.Replace("WSSUMITS\","")

# Variables for RobocopyPS and PoShLog
$modRobocopy = "RobocopyPS"
$chkRobocopy = Get-Module -Name $modRobocopy
$modPoShLog = "PoShLog"
$chkPoShLog = Get-Module -Name $modPoShLog


# Configure PoShLog
$LogFilePath = "C:\Logs\Robocopy.log"
$Log = New-Log -Name Robocopy -FilePath $LogFilePath

try {
        # Check if PoShLog module is installed and if not install the current version
    if (-not $chkPoShLog) {
        Install-Module -Name $modPoShLog
    }
        Write-Log -Logger $logger -Message "PoShLog module installed"
    else {
        Write-Log -Logger $logger -Message "PoShLog module already installed"
    }
        # Import PoShLog module
    Import-Module -Name $modPoShLog
        Write-Log -Logger $logger -Message "PoShLog module imported"

    # Check if RobocopyPS module is installed and if not install the current version
    if (-not $chkRobocopy) {
        Install-Module -Name $modRobocopy
    }
        Write-Log -Logger $logger -Message "RobocopyPS module installed"
    else {
        Write-Log -Logger $logger -Message "RobocopyPS module already installed"
    }
        # Import RobocopyPS module
    Import-Module -Name $modRobocopy
        Write-Log -Logger $logger -Message "RobocopyPS module imported"

    # Create parameters for Robocopy
    $paramRobo = @{
        Source = "C:\Users\$usrString"
        Destination = "\\vision2\backups\$usrString"
        Force = $true
        Threads = 16
        Retry = 0
        Recurse = $true
        Verbose = $true
    }

    # Execute Robocopy command
    Write-Log -Logger $Log -Message "Executing Robocopy command"
    Invoke-RoboCopy @paramRobo -DirectoryCopyFlags D,A,T -ExcludeFileName *.DAT*,*.dll* -ExcludeDirectory *OneDrive*,*AppData*,*Application*
    Write-Log -Logger $Log -Message "Robocopy command completed successfully"

} catch {
    # Log any errors that occur
    Write-Log -Logger $Log -Level Error -Message $_.Exception.Message
}