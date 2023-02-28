# General Variables
$cred = Get-Credential
$pathGroupDrive = "\\wssu.edu\ramfile\groups"

# Map group drive using the submitted credentials
New-PSDrive -Name "G" -PSProvider "FileSystem" -Root $pathGroupDrive -Persist -Credential $cred
