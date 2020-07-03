$results = foreach ($mbx in (get-mailbox -resultsize Unlimited)) {
    Get-MailboxFolderPermission $mbx.samaccountname | select identity, User, Accessrights
}


$results | select {$_.Identity},{$_.User},{$_.Accessrights} | Out-GridView