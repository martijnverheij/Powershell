# Replicate the DHCP server configuration from Sheldon to it's replication partners in the failover relationship
# Script is invoked by a scheduled task
# Debugging output is stored in a simple text logfile

Invoke-DhcpServerv4FailoverReplication –ComputerName sheldon.intellimagic.local –Name immaster.intellimagic.local-sheldon.intellimagic.local -Force -Verbose *>>C:\bin\replicate_dhcp\replicate_dhcp.log