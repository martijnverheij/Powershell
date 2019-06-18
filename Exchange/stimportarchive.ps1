param([string] $data ="\\swi334\pst$",
      [string] $logfile = "d:\scripts\log\import-pst.log",
      [string] $transcriptfile = "d:\scripts\log\import-pst.txt",
      [bool] $append = $false,
      [bool]  $batch = $false
)

function log($tekst,$logfile,$color="")
{
   $dd = get-date -format "yyy-MM-dd HH:mm:ss"
   if ($logfile -ne "")
   {
      "$dd $tekst" | out-file -filepath $logfile -encoding UNICODE -append
   }
   if (-not $batch)
   {
      if ($color -eq "")
      {
          write-host "$dd $tekst" 
      }
      else
      {
          write-host "$dd $tekst" -foregroundcolor $color
      }
   }
}

function importaction($name,$mbx,$file,$batchname,$logfile)
{
   try
   {
      $mbxaction = New-MailboxImportRequest -name $name -mailbox $mbx.samaccountname -isarchive -filepath $file -batchname $batchname -TargetRootFolder "ST-archive" -erroraction stop
   }
   catch
   {
      $errormessage = $_.ToString()
      log "Error:  import request failed with $errormessage" $logfile
   }
   if ($mbxaction -ne $null)
   {
     log "import request: $($mbxaction.name) of mailbox $($mbxaction.mailbox)" $logfile
     $global:importhash.add($mbxaction.name,$file)
   } 
}

function checklength($user,$length,$logfile)
{
   $arch = get-mailbox $user | select archivequota
   $max = $arch.archivequota.value.togb()
   $ret = $false
   if ($length -le $max)
   {
      $ret = $true
   }
   else
   {
      log "Archive file $($file.name) has a size of $length which is greater than max archive size (=$max GB)" $logfile "Darkgreen"
   }
   return $ret
}
  


function importpst($folder,$file,$length,$batchname,$logfile)
{
    log "Import file $file" $logfile
    $user = $file -replace "archive_" -replace ".pst"
    if (checklength $user $length $logfile)
    {
       try
       {
          $mbx = get-mailbox $user -erroraction stop
       }
       catch
       {
          log "No mailbox found for $user" $logfile
          $mbx = $null
       }
       if ($mbx -ne $null)
       {
          importaction "import archive $user" $mbx ($folder + "\\" + $file) $batchname $logfile
       }
   }
   
}

function reportfailedimport($failed,$logfile)
{
   foreach($exp in $failed)
   {
      $aa= $exp | Get-MailboximportRequestStatistics  | select name,filepath,failurecode,failuretype,message,FailureContext,SourceMailboxIdentity
      $regel= "batchname: $($aa.name)  Mailbox:$($aa.SourceMailboxIdentity) Filepath:$($aa.filepath)  FailureCode:$($aa.failurecode)   Failuretype:$($aa.failuretype)  Message:$($aa.mesaage)   FailureContext:$($aa.FailureContext)"
      log $regel $logfile
      $oldfile = $global:importhash.get_item($aa.name)
      $newfile = $oldfile + ".failed"
      rename-item $oldfile -newname $newfile
   }
}

$importbatchname= "import_pst_" + $(get-date -format "yyyy-MM-dd_HH:mm:ss")
start-transcript $transcriptfile

if (!$append)
{
    if (test-path $logfile)
    {
      remove-item $logfile -force
    }
}

log "Import Start" $logfile
log "batchname: $importbatchname" $logfile

$files = @(get-childitem -path $data -filter "*.pst" | select name,@{n='length';e={[math]::round($_.length/1gb + 0.5)}} )
#$files = @(get-childitem -path $data -filter "archive_Petra.Mebius@st.nl.pst" | select name,@{n='length';e={[math]::round($_.length/1gb + 0.5)}} )
#$files = @(get-childitem -path $data -filter "archive_Fred.Vermue@st.nl.pst" | select name,@{n='length';e={[math]::round($_.length/1gb + 0.5)}} )
log "Count files: $($files.count)" $logfile
$maxarchive=4
$global:importhash = @{}
foreach($file in $files)
{
#   if ($file.length -le $maxarchive)
#   {
        importpst $data $file.name $file.length $importbatchname $logfile
#   }
#   else
#   {
#      log "Archive file $($file.name) has a size of $($file.length) which is greater than max archive size (=$maxarchive GB)" $logfile "Darkgreen"
#   }
}

$ss=@(get-mailboximportrequest -batchname $importbatchname | where { $_.status -ne "failed" })
$count = $ss.count
while($count -gt 0)
{
  log "NO of import requests:  $count" $logfile
  $count1= $count
  $tel=1
  foreach($name in $ss)
  {
    if ($name.status -eq "Completed")
    {
        log "$($name.name) Completed" $logfile
        remove-mailboximportrequest -identity $name -Confirm:$false
        $oldfile = $global:importhash.get_item($name.name)
        $newfile = $oldfile + ".done"
        rename-item $oldfile -newname $newfile
        $count--
        $tel++
    }
  }
  if ($count -gt 0)
  {
    log "sleep 120 sec..." $logfile
    sleep -s 120
    $ss=@(get-mailboximportrequest -batchname $importbatchname | where { $_.status -ne "failed" })
    $ss | Get-MailboxImportRequestStatistics
    $count = $ss.count
  }
}

$failed=@(get-mailboximportrequest -batchname $importbatchname | where { $_.status -eq "failed" })

log "No failed import requests: $($failed.count)" $logfile

if ($failed.count -gt 0)
{
    reportfailedimport $failed $logfile
}

log "Einde Script" $logfile
stop-transcript
