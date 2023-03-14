# Variables that creates an array of the accounts to be excluded from removal process
$acctsExcluded = "ramadmin"
$localHost = HOSTNAME.EXE

# Method that will delete all of the user profiles on a computer, except the accounts listed in the $acctsExcluded variable
Get-CimInstance -ComputerName $localHost -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -notin $acctsExcluded } | Remove-CimInstance
