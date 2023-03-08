# PoShLog Module API 1.0.0
# General Vaiables
$modPoShLog = "PoShLog"
$chkPoShLog = Get-Module -Name $modRobocopy

# Check to see if PoShLog is installed. If not, the most current version will be installed
if (-Not $chkPoShLog) {
    Install-Module -Name $modPoShLog
}

# Import PoShLog into current PowerShell session
Import-Module PoShLog

# Create new logger
# This is where you customize, when and how to log
New-Logger |
    Set-MinimumLevel -Value Verbose | # You can change this value later to filter log messages
    # Here you can add as many sinks as you want - see https://github.com/PoShLog/PoShLog/wiki/Sinks for all available sinks
    Add-SinkConsole |   # Tell logger to write log messages to console
    Add-SinkFile -Path 'C:\Data\my_awesome.log' | # Tell logger to write log messages into file
    Start-Logger

# Test all log levels
Write-VerboseLog 'Test verbose message'
Write-DebugLog 'Test debug message'
Write-InfoLog 'Test info message'
Write-WarningLog 'Test warning message'
Write-ErrorLog 'Test error message'
Write-FatalLog 'Test fatal message'

Close-Logger