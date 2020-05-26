# Service Stop Script
#
# v1.1
# For Exchange 20xx Servers
#
 
$services = Get-WmiObject Win32_Service
foreach ($line in $services) {
    $service = $line.displayname
    $status = $line.state
    $startup = $line.startmode
    if ($service -like "Microsoft Exchange*") {
        if (($status -eq "Running") -and ($startup -eq "Auto")) {
            write-host $service" needs to be stopped.  Stopping it now."
            stop-service $service -force
        }
# Added for Edge Transport Server
    if ($service -like "Active Directory Web Services") {
        if (($status -eq "Running") -and ($startup -eq "Auto")) {
            write-host $service" needs to be stopped.  Stopping it now."
            stop-service $service -force
        }
    }
    }
}
foreach ($line in $services) {
    $service = $line.displayname
    $status = $line.state
    $startup = $line.startmode
    if ($service -like "Microsoft Exchange*") {
        get-service $service
    }
}
