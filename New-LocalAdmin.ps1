$user = Read-Host "Enter username"
$password = Read-Host "Enter new password" -AsSecureString
Write-Host "Creating $user account ..."
New-LocalUser "$user" -Password $password -FullName "$user" -Description "$user" -Verbose

# Write-Host "Adding $user to Local Administrators group ..."
# Add-LocalGroupMember -Group "Administrators" -Member "$user" -Verbose
