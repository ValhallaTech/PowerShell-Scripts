# Variables that create an array of the accounts to be excluded from removal process
$acctsExcluded = @("ramadmin", "S-1-5-18", "S-1-5-19", "S-1-5-20")

# Method that will delete all of the user profiles on a computer, except the accounts listed in the $acctsExcluded variable
Get-CimInstance -Class Win32_UserProfile | Where-Object { ($_.LocalPath -ne $null) -and ($_.LocalPath.split('\')[-1] -notin $acctsExcluded) -and ($_.SID -notin $acctsExcluded) } | Remove-CimInstance
