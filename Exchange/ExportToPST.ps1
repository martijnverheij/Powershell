param([string] $data ="\\EXMDB01\pst$",
      [string] $logfile = "C:\scripts\PSTlog\export-pst.log",
      [string] $transcriptfile = "C:\scripts\PSTlog\export-pst.txt",
      [bool] $append = $true,
      [bool]  $batch = $false
)

function log($tekst,$logfile)
{
   $dd = get-date -format "yyyy-MM-dd HH:mm:ss"
   if ($logfile -ne "")
   {
      "$dd $tekst" | out-file -filepath $logfile -encoding UNICODE -append
   }
   if (-not $batch)
   {
      write-host "$dd $tekst"
   }
}

function getstadress1($mbx)
{
   $name= $mbx.PrimarySmtpAddress
   $name
}

function getstadress($mbx)
{
   $aa= $mbx.primarysmtpaddress -replace "@HasBeenMigratedTo.Exchange2010","" -replace ".st.nl","@st.nl" 
   $aa 
}

function exportmbxaction($name,$mbx,$file,$batchname,$logfile)
{
   $tt = $mbx.displayname
   log "mailbox archive $tt exporting to $file" $logfile
   try
   {
      $mbxaction = new-MailboxExportRequest -name $name -mailbox $mbx.samaccountname -isarchive -filepath $file -batchname $batchname -erroraction stop
   }
   catch
   {
      $errormessage = $_.ToString()
      log "Error:  export request failed with $errormessage" $logfile
   }
   if ($mbxexport -ne $null)
   {
     log "export request: $($mbxexport.name) of mailbox $($mbxexport.nailbox)" $logfile
   }
}

function exportmbx($mbx,$data,$batchname,$logfile)
{
  $display = getstadress $mbx
  $dd=get-date -format "yyyyMMdd"
  log "export mailbox: $($mbx.samaccountname) Exchangeguid:$($mbx.exchangeguid) ArchiveGuid:$($mbx.archiveguid)  Display: $display" $logfile
  if ($display -ne "")
  {
     if ($mbx.archivedatabase -ne $null)
     {
 #        $file = $data + "\\archive_" + $display + "_$dd.pst"
         $file = $data + "\archive_" + $display + ".pst"
         if (test-path $file)
         {
            log "Error: $file already exists" $logfile
         }
         else
         {
            exportmbxaction "export archive $display" $mbx $file $batchname $logfile
         }
    }
	else
    {
        log "$($mbx.samaccountname) no archive mailbox"  $logfile
    }
  }
  else
  {
       log "$($mbx.samaccountname) no Email address found"  $logfile
  }
  log "-------------------------------------" $logfile
}

function reportfailedexport($failed,$logfile)
{
   foreach($exp in $failed)
   {
      $aa= $exp | Get-MailboxExportRequestStatistics  | select name,filepath,failurecode,failuretype,message,FailureContext,SourceMailboxIdentity
      $regel= "batchname: $($aa.name)  Mailbox:$($aa.SourceMailboxIdentity) Filepath:$($aa.filepath)  FailureCode:$($aa.failurecode)   Failuretype:$($aa.failuretype)  Message:$($aa.mesaage)   FailureContext:$($aa.FailureContext)"
      log $regel $logfile
   }
}

import-module activedirectory

$exportbatchname= "export_pst_" + $(get-date -format "yyyy-MM-dd_HH:mm:ss")
start-transcript $transcriptfile

if (!$append)
{
    if (test-path $logfile)
    {
      remove-item $logfile -force
    }
}

$arr = @()
$regels = gc "C:\Scripts\Archief\archives.txt" 
foreach($user in $regels)
{
   $user = $user.trim()
   $arr += $user
}

log "export batchname:  $exportbatchname" $logfile
#$arrmbx = @(get-mailbox -resultsize unlimited -erroraction stop )
#$arrmbx = @(get-mailbox avensus_t -erroraction stop )
#$arrmbx = @(get-mailbox bku_*)
$arrmbx1 = @(Get-Mailbox BKU* | where{$_.WhenCreated -gt "2-1-2018"})
$arrmbx=@()
foreach($mbx in $arrmbx1)
{
   $add = getstadress $mbx
   if ($arr -notcontains $add)
   {
     $arrmbx += $mbx
     write-host $add
   }
}


log "Count Mbx: $($arrmbx.count)" $logfile

foreach($mbx in $arrmbx)
{
  exportmbx $mbx $data $exportbatchname $logfile
}

$ss=@(get-mailboxexportrequest -batchname $exportbatchname | where { $_.status -ne "failed" })
$count = $ss.count
while($count -gt 0)
{
  log "NO of export requests:  $count" $logfile
  $count1= $count
  $tel=1
  foreach($name in $ss)
  {
    if ($name.status -eq "Completed")
    {
        log "$($name.name) Completed" $logfile
        Remove-mailboxexportRequest -Identity $name -Confirm:$false
        $count--
        $tel++
    }
  }
  if ($count -gt 0)
  {
    log "sleep 120 sec..." $logfile
    sleep -s 120
    $ss=@(get-mailboxexportrequest -batchname $exportbatchname | where { $_.status -ne "failed" })
    $count = $ss.count
  }
}

$failed=@(get-mailboxexportrequest -batchname $exportbatchname | where { $_.status -eq "failed" })

log "No failed export requests: $($failed.count)"  $logfile

if ($failed.count -gt 0)
{
    reportfailedexport $failed $logfile
}

log "Einde Script" $logfile
stop-transcript
