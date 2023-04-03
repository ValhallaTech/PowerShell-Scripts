$systemDrive = $env:SystemDrive
$logPath = "$systemDrive\Logs\DriverMapper.log"

# Splatting Variables
$driveParams = @{
    Name = "G"
    PSProvider = "FileSystem"
    Root = "\\wssu.edu\ramfile\groups"
    Persist = $true
}

try {
    # Map group drive
    New-PSDrive @driveParams -ErrorAction Stop
    Write-Output "Mapped group drive successfully." > $logPath
}
catch {
    Write-Error "Failed to map group drive: $_" > $logPath -ErrorAction Stop
}
