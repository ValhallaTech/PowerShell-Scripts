# Variable that creates an array of the accounts to be excluded from removal process
$acctsExcluded = "ramadmin"

# Method that will delete all of the user profiles on a computer, except the accounts listed in the above array
Get-CimInstance -ComputerName computer1,computer2 -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -notin $acctsExcluded } | Remove-CimInstance
