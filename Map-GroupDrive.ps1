# Map group drive using these parameters
$paramMapping = @{
  Name = "G"
  PSProvider = "FileSystem"
  Root = "\wssu.edu\ramfile\groups"
  Persist = $true
  Credential = (Get-Credential)
}

# Map group drive using the submitted credentials
New-PSDrive @paramMapping
