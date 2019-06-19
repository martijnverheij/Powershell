import-module ActiveDirectory

$datum = Get-Date
$maandnr = Get-Date -UFormat %m
#$maandnr = "02"
$jaar = Get-Date -UFormat %Y
$reportfile = "C:\temp\licreport.txt"

If ($maandnr -eq "01") {$maand = "january"}
If ($maandnr -eq "02") {$maand = "february"}
If ($maandnr -eq "03") {$maand = "maart"}
If ($maandnr -eq "04") {$maand = "april"}
If ($maandnr -eq "05") {$maand = "may"}
If ($maandnr -eq "06") {$maand = "june"}
If ($maandnr -eq "07") {$maand = "july"}
If ($maandnr -eq "08") {$maand = "august"}
If ($maandnr -eq "09") {$maand = "september"}
If ($maandnr -eq "10") {$maand = "october"}
If ($maandnr -eq "11") {$maand = "november"}
If ($maandnr -eq "12") {$maand = "december"}
#$maand = "february"

#Change values
$DestMail = "EMAILADRES","EMAILADRES"
$FromMail = "support@KLANT.nl"
$SubjectMail = $Maand + " :Licence report for KLANT"
$MailServer = "MAILSERVER"

$UsersOU = "ou=USERS,dc=CONTOSO,dc=COM"
$RoomsOU = "ou=ROOMS,dc=CONTOSO,dc=COM"
$SharedOU = "ou=Shared,dc=CONTOSO,dc=COM"
$TeamsOU = "ou=Teams,dc=CONTOSO,dc=COM"
$DisabledOU = "OU=" + $maandnr + " - " + $maand + ",OU=" + $jaar + ",OU=Gebruikers - Disabled,dc=CONTOSO,dc=COM"

$TotalUsers = (Get-ADUser -Filter * -SearchBase $UsersOU).count
$OKTUsers = (Get-ADUser -Filter * -SearchBase $UsersOU -Properties company | ? {$_.company -like "Ouder*"}).count
$GGDUsers = (Get-ADUser -Filter * -SearchBase $UsersOU -Properties company | ? {$_.company -like "GGD*"}).count
$ExterneUsers = (Get-ADUser -Filter * -SearchBase $UsersOU -Properties company | ? {$_.company -like "Externe*"}).count
$SAGUsers = (Get-ADUser -Filter * -SearchBase $UsersOU -Properties company | ? {$_.company -like "SAG*"}).count
$TelRooms = (Get-ADUser -Filter * -SearchBase $RoomsOU).count
$TelShared = (Get-ADUser -Filter * -SearchBase $SharedOU).count
$TelTeams = (Get-ADUser -Filter * -SearchBase $TeamsOU).count
$TelDisabledThisMonth = (Get-ADUser -Filter * -SearchBase $DisabledOU).count
$TelTeFacturen = $TotalUsers+$TelDisabledThisMonth

echo "- Users rapporteren naar Microsoft tbv SPLA licenties" > $reportfile
echo "- Totaal factureren naar KLANT" >> $reportfile
echo "- Alleen mail van de laatste dag van de maand gebruiken. Overige mail is test" >> $reportfile
echo "- Indien er geen aantal staat is het aantal: 1" >> $reportfile
echo $datum >> $reportfile
echo Total Users:          $TotalUsers >> $reportfile
echo OKT Users:          $OKTUsers >> $reportfile
echo GGD Users:          $GGDUsers >> $reportfile
echo Externe Users:          $ExterneUsers >> $reportfile
echo SAG Users:          $SAGUsers >> $reportfile
echo Rooms:                $TelRooms >> $reportfile
echo Shared:               $TelShared >> $reportfile
echo Teams:                $TelTeams >> $reportfile
echo "Disabled this month:" $TelDisabledThisMonth >> $reportfile
echo "========================================" >> $reportfile
echo "Totaal te factureren en te rapporteren: " $TelTeFacturen >> $reportfile


$BodyMail = Get-Content $reportfile | Out-String
Send-MailMessage -To $DestMail -Subject $SubjectMail -Body $BodyMail -Attachment $reportfile -From $FromMail -SmtpServer $MailServer -Priority High
del $reportfile
