$localPath = "V:"
$remotePath = "\\vision2\backups"
$credential = Get-Credential

Write-Host "Mapping vision2 folder ..."
try {
    New-SmbMapping -LocalPath $localPath -RemotePath $remotePath -UserName $credential.UserName -Password $credential.GetNetworkCredential().Password
}
catch
{
    Write-Error -Exception ([System.UnauthorizedAccessException]::new('Unauthorized Access')) -ErrorAction Stop
}

Write-Host "Calling Copy-vision2.bat ..."
cmd.exe /c ".\Copy-vision2.bat"
Pause
Write-Host "Removing vision2 from map ..."
Remove-SmbMapping V: -Force
