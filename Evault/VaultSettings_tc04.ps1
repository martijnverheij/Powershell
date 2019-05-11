<#
  .SYNOPSIS
  # Copyright 2015 EVault, Inc.  All rights reserved.
        # Script to get\set vault settings. The script can be executed on the vault machine only
 
 
        #Usage
        #To set vault setting: .\VaultSettings.ps1 set LogTraceLevel 1
        #To get vault setting: .\VaultSettings.ps1 get LogTraceLevel
 
 
  .DESCRIPTION
  This VaultSettings_tc01.ps1 is an edited version of the VaultSettings.ps1 that comes with Director 8.0 with added Help information by Thierry Cailleau
        This sysnopsis alloows for embedded help, T
        Try:
            PS C:\Users\Administrator> cd "C:\Program Files\EVault\InfoStage\Director\Scripts"
        Then:
            PS C:\Program Files\EVault\InfoStage\Director\Scripts> help .\VaultSettings_tc01.ps1 -full
 
 
  .PARAMETER  op
  Is an enumerated value either:
        set
        get
 
 
  .PARAMETER  par
  Is a valid parameter, also an enumerated value which can be edited with new valid parameters as supported by shared.dll
 
 
        # From Vault SQL table "dbo.GlobalParameters" --------
  AcceptEncryptedDataOnly
  AgentConnectAddresses
  AlertOnError
  AlertsTo
  BillingDataDir
  BillingReportingOriginal
  ClusterReportingNode
  CompletedSessionLifetime
  DatabaseDirectory
  DatabaseSchemaVersion
  DateInstalled
  DateUpgraded
  DisableReplication1to1
  DisableReplicationNto1
  EnableDemoReg
  EnableMigrationToTieredStorage
  Encryption
  ErrorsTo
  FromAddressOverride
  ListenCommandPort
  ListenDataPort
  ListenerSocketLimit
  ListenerSocketTimeout
  ListeningPorts
  MailOnFailure
  MailOnSuccess
  MaintenanceJobs1
  MaintenanceJobs2
  MaintenanceJobs3
  MaintenanceJobs4
  MaximumJobs
  NodeStatusTTLSec
  NodeStatusUpdateIntervalSec
  OpenPoolFileLimit
  PerfCount1Name
  PerfCount1Threshold
  PerfCount2Name
  PerfCount2Threshold
  ProcessedEventLifetime
  PurgeMaxCopies
  PurgeMaxDays
  RegPOPServer
  ReplFailureNotification
  ReplicationStateLog
  RetryCount
  RetryTimeoutMin
  SendDeviceNotification
  SMTPServer
  SrvLicKeys
  TransferProtocol
  UncoupledPassive # 0 or 1
  UseCustQuotas
  VVSalesGroup
 
        # Addition SQL table "dbo.GlobalParameters" supported entries ------
  SatelliteAsSales # -val 0
  InternalSyncLockTimeout # value of 300000 for 5 min default 120000 (in msec) for 2 min
  InlineReplicationEnabled # create this entry and set it to value 0 to disabled "inline replication"
 
        # From default registry---------------------------
  ServerRootDirectory
  VaultServiceAccountCreatedByInstaller
  VVServerVersion
  UseLocalLibrariesPath
  UseLocalLibraries
  InstallCode
  SQLAllowAccess
  SQLCommandTimeout_cached_locally
  SQLConnectionTimeout_cached_locally
  SQLRetryDelay_cached_locally
  SQLRetryLimit_cached_locally
  SQLMaxConnectionsPerProcess_cached_locally
  VVSalesGroup
 
 
        # From known Valid registry entries sometime needed by the developers for debugging
        LogTraceLevel
 
 
  .EXAMPLE
  PS C:\Users\Administrator> cd "C:\Program Files\EVault\InfoStage\Director\Scripts"
        PS C:\Program Files\EVault\InfoStage\Director\Scripts> .\VaultSettings.ps1 -op get -par SrvLicKeys
      
        Gets the list of licenses used on that Vault
 
 
  .EXAMPLE
  PS C:\Program Files\EVault\InfoStage\Director\Scripts> .\VaultSettings.ps1 -op set -par LogTraceLevel -val 1
        The value '1' was successfully assigned to the setting 'LogTraceLevel'
 
 
        This creates a new valid entry LogTraceLevel Type REG_SZ in the Vaults' registry:
        HKEY_LOCAL_MACHINE\SOFTWARE\EVault\InfoStage\Director\Config
 
 
  .EXAMPLE
        PS C:\Program Files\EVault\InfoStage\Director\Scripts> .\VaultSettings.ps1 -op get -par ReplicationStateLog
        ReplicationStateLog: VV_LOGS:\ReplicationStatus-560D3025-0754-0768.LOG
 
 
  .INPUTS
  System.String,System.Int32,System.Int64
 
 
  .OUTPUTS
  System.String,System.Int32,System.Int64
 
 
  .NOTES
  Additional information about the function go here.
 
 
  .LINK
  about_functions_advanced
 
 
  .LINK
  about_comment_based_help
 
 
#>
param(
[Parameter(Mandatory=$True, Position=0, HelpMessage="Enter operation type ([get] or [set])")]
[ValidateSet("get","set")]
[string]$op,
[Parameter(Mandatory=$True, Position=1, HelpMessage="Enter setting name")]
[ValidateSet("AcceptEncryptedDataOnly","AgentConnectAddresses","AlertOnError","AlertsTo","BillingDataDir","BillingReportingOriginal","ClusterReportingNode","CompletedSessionLifetime","DatabaseDirectory","DatabaseSchemaVersion","DateInstalled","DateUpgraded","DisableReplication1to1","DisableReplicationNto1","EnableDemoReg","EnableMigrationToTieredStorage","Encryption","ErrorsTo","FromAddressOverride","ListenCommandPort","ListenDataPort","ListenerSocketLimit","ListenerSocketTimeout","ListeningPorts","MailOnFailure","MailOnSuccess","MaintenanceJobs1","MaintenanceJobs2","MaintenanceJobs3","MaintenanceJobs4","MaximumJobs","NodeStatusTTLSec","NodeStatusUpdateIntervalSec","OpenPoolFileLimit","PerfCount1Name","PerfCount1Threshold","PerfCount2Name","PerfCount2Threshold","ProcessedEventLifetime","PurgeMaxCopies","PurgeMaxDays","RegPOPServer","ReplFailureNotification","ReplicationStateLog","RetryCount","RetryTimeoutMin","SendDeviceNotification","SMTPServer","SrvLicKeys","TransferProtocol","UncoupledPassive","UseCustQuotas","VVSalesGroup","SatelliteASSales","InternalSyncLockTimeout","InlineReplicationEnabled","ServerRootDirectory","VaultServiceAccountCreatedByInstaller","VVServerVersion","UseLocalLibrariesPath","UseLocalLibraries","InstallCode","SQLAllowAccess","SQLCommandTimeout_cached_locally","SQLConnectionTimeout_cached_locally","SQLRetryDelay_cached_locally","SQLRetryLimit_cached_locally","SQLMaxConnectionsPerProcess_cached_locally","VVSalesGroup","LogTraceLevel")]
[string]$par,
[Parameter(Mandatory=$False, Position=2, HelpMessage="Enter setting value")]
[string]$val = "")
 
 
$sharedDll = "$($env:vault)\prog\shared.dll"
$result = 0
switch ($op)
{
   "set"
   {
      $setMethodDef = "[DllImport(@""$($sharedDll)"", CharSet = CharSet.Ansi)] public static extern int setVaultSetting(String pName, String pValue);"
      $setMethod = Add-Type -MemberDefinition $setMethodDef -Name "SetMethod$((Get-Date).ticks)" -PassThru
      $result = $setMethod::setVaultSetting($par, $val)
      if ($result -eq 1)
      {
         Write-Output "The value '$($val)' was successfully assigned to the setting '$($par)'"
      }
      else
      {
         Write-Error "Failed to assign value '$($val)' to the setting '$($par)'"
      }
   }
 
   "get"
   {
      $getMethodDef = "[DllImport(@""$($sharedDll)"", CharSet = CharSet.Ansi)] public static extern int getVaultSetting(String pName, System.Text.StringBuilder pValue, int pValueBufSize);"
      $getMethod = Add-Type -MemberDefinition $getMethodDef -Name "GetParam$((Get-Date).ticks)" -PassThru
      $paramValueBuf = New-Object -TypeName System.Text.StringBuilder 512    
      $result = $getMethod::getVaultSetting($par, $paramValueBuf, $paramValueBuf.Capacity)
      switch ($result)
      {
         -1 { Write-Error "Failed to get the value of the setting '$($par)'" }
          0 { Write-Warning "$($par): [Unavailable]" }
          default { Write-Output "$($par): $($paramValueBuf.ToString())" }
      }
   }
}
exit ($result -ne 1)