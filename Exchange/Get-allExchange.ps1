$MB = Get-Mailbox -resultSize unlimited
$MB | foreach{     
  $AccountEnabled = "Enabled"
  $user = Get-User $_ | select DisplayName, FirstName, LastName, company, department, title, samAccountName, UserAccountControl, City, StateOrProvince, CountryOrRegion, Office

  $mbx = $_ | select ServerName, samAccountName, Name, Alias, PrimarySmtpAddress,RecipientTypeDetails, DistinguishedName #, ProhibitSendQuota,ProhibitSendReceiveQuota,UseDatabaseQuotaDefaults,IssueWarningQuota 
  write-host "Processing: " $user.DisplayName "("$user.samAccountName")"

$ADSPath = "LDAP://" + $mbx.DistinguishedName
  $ADUser = [ADSI]$ADSPath
  $Description = [String]$ADUser.Description # Required to convert the returned value to a string

$mbx | add-member -type noteProperty -name DisplayName -value $User.DisplayName # Not part of the mailbox properties, so using Get-User property and adding it to $mbx variable
  $mbx | add-member -type noteProperty -name FirstName -value $User.FirstName
  $mbx | add-member -type noteProperty -name LastName -value $User.LastName
  $mbx | add-member -type noteProperty -name Company -value $User.company
  $mbx | add-member -type noteProperty -name Department -value $User.department
  $mbx | add-member -type noteProperty -name Title -value $User.title
  $mbx | add-member -type noteProperty -name City -value $User.City
  $mbx | add-member -type noteProperty -name StateOrProvince -value $User.StateOrProvince
  $mbx | add-member -type noteProperty -name CountryOrRegion -value $User.CountryOrRegion
  $mbx | add-member -type noteProperty -name Office -value $User.Office
  $mbx | add-member -type noteProperty -name Description -value $Description # Not avaliable from Exchange cmdlets, so using ADSI


If ($User.UserAccountControl -contains "AccountDisabled"){
   $AccountEnabled = "Disabled"
  }
  $mbx | add-member -type noteProperty -name UserAccountControl -value $AccountEnabled
  
  Get-MailboxStatistics $_ | ForEach{ 
   $MBSize = $_.TotalItemSize.Value.ToMB() 
   $MBItemCount = $_.ItemCount
   $MBDB = $_.DatabaseName
   $MBLastLogonTime = $_.LastLogonTime
   $ExchangeDN = $_.LegacyDN
     }
     
  $mbx | add-member -type noteProperty -name TotalItemSizeinMB -value $MBSize # Get attributes from Get-MailboxStatistics  and add them to $mbx variable
  $mbx | add-member -type noteProperty -name ItemCount -value $MBItemCount
  $mbx | add-member -type noteProperty -name DatabaseName -value $MBDB
  $mbx | add-member -type noteProperty -name LastLogonTime -value $MBLastLogonTime
  $mbx | add-member -type noteProperty -name legacyExchangeDN -value $ExchangeDN
  

#write-host "DisplayName: "$mbx.DisplayName "`tMailbox Size: "$mbx.TotalItemSizeinMB "`tMailbox Size: "$mbx.ItemCount "LastLogonTime: "$mbx.LastLogonTime
#write-host 

# Write-host $mbx.ServerName,"N/A", $mbx.DatabaseName, $mbx.Name, $mbx.FirstName, $mbx.LastName, $mbx.DisplayName, $mbx.Alias, $mbx.PrimarySmtpAddress, $mbx.samAccountName, $mbx.UserAccountControl, $mbx.TotalItemSizeinMB, $mbx.Description, $mbx.Department, $mbx.Title, $mbx.City, $mbx.StateOrProvince, $mbx.CountryOrRegion, $mbx.DistinguishedName, $mbx.LastLogonTime, $mbx.Office, $mbx.legacyExchangeDN
  $mbx | Select ServerName,"N/A", DatabaseName, Name, FirstName, LastName, DisplayName, Alias, PrimarySmtpAddress, RecipientTypeDetails, samAccountName, UserAccountControl, TotalItemSizeinMB, ItemCount, Company, Description, Department, Title, City, StateOrProvince, CountryOrRegion, DistinguishedName, LastLogonTime, Office, legacyExchangeDN
} | export-csv -NoTypeInformation c:\_Avensus\MailboxData3.csv -Encoding unicode
$MB = $Null
$user = $Null
$ADUser = $Null

$MBX = $Null
