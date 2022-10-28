# Store service tag in variable
$serviceTag = Get-WmiObject win32_SystemEnclosure | select serialnumber -ExpandProperty serialnumber

$serviceTag
