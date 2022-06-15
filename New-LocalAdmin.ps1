$password = Read-Host "Enter new password" -AsSecureString
Write-Host "Creating DSAdmin01 user account ..."
New-LocalUser "DSAdmin01" -Password $password -FullName "DSAdmin01" -Description "DSAdmin01" -Verbose

Write-Host "Adding DSAdmin01 to Local Administrators group ..."
Add-LocalGroupMember -Group "Administrators" -Member "DSAdmin01" -Verbose
