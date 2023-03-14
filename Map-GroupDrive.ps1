# Grouper Mapper 2.0.0

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

# Map group drive using these parameters
$paramMapping = @{
  Name = "G"
  PSProvider = "FileSystem"
  Root = "\\wssufs2\ramfile\groups"
  Persist = $true
  Credential = (Get-Credential)
}

# Map group drive using the specified parameters
New-PSDrive @paramMapping
