function Initialize-Module ($module) {

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $module}) {
        write-host "Module $module is already imported."
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $module}) {
            Import-Module $module -Verbose
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $module | Where-Object {$_.Name -eq $module}) {
                Install-Module -Name $module -Force -Verbose -Scope CurrentUser
                Import-Module $module -Verbose
            }
            else {

                # If the module is not imported, not available and not in the online gallery then abort
                write-host "Module $module not imported, not available and not in an online gallery, exiting."
                EXIT 1
            }
        }
    }
}

Load-Module "ModuleName" # Use "PoshRSJob" to test it out