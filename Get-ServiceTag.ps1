# Store service tag in variable
$serviceTag = Get-WmiObject win32_SystemEnclosure | Select-Object serialnumber -ExpandProperty serialnumber

$serviceTag
