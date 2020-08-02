$results = foreach ($mbx in (get-mailbox -resultsize unlimited)) {
    Get-MailboxFolderPermission ($mbx.samaccountname + ":\calendar") | select @{Name='Name';Expression={$mbx.Name}}, FolderName,User,Accessrights
}


$results | select {$_.Name},{$_.FolderName},{$_.User},{$_.Accessrights} | Out-GridView