$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://localhost/
Import-PSSession $session
get-mailboxstatistics -Database "Omroep Bo" | Select Displayname, LastLogonTime | Export-CSV -path C:\temp\Lastlogon.csv
