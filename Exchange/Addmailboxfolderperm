<# 
 .SYNOPSIS 
    
    Add mailbox folder permission to the delegates for user and resource mailboxes

 .DESCRIPTION 

    Important task of the Exchange admin to assign the folder permission to the delegates 
    when new delegates added to the generic mailbox and Resource mailboxes.
    the script simplify the task and eliminate the manual errors 

    

 .NOTES 
    Author  : Kamaraj Ulaganathan
    Email: kamaraj0926@outlook.com 
    Requires: PowerShell Version 1.0

    #> 




Write-host "

Assign Mailbox folder Permission
--------------------------------

1.Assign Folder permission to Single folder

2.Assign Folder Permission to All folders(includes user created,default,recoverable mailbox folders)

3.Assign Folder permission only to the default folders(inbox,calendar,....)

4.Assign Folder permission only to the user created folders

5.Exit " -ForeGround "Cyan"

$option = Read-host "Choose the Option"

switch ($option)
{

1 {

$Mailbox = Read-Host "Enter Mailbox ID "

$Folder = Read-Host "Enter the FOLDER NAME ( Examplles : Inbox,calendar...)"

$delegate = Read-Host "Enter Delegate ID "

$Permission = Read-Host "Enter Type of Permission(Author, Editor, Owner, Reviewer, none)"

$foldername = $Mailbox + ":\" + $folder



If ($folder -ne "")

{


Add-MailboxFolderPermission $foldername -User $delegate -AccessRights $Permission -confirm:$true

}

Else

{ Write-Host " Please Enter Folder name " -ForeGround "red"}



;break

}

2
{

$Mailbox = Read-Host "Enter Mailbox ID" 

$delegate = Read-Host "Enter Delegate ID "

$Permission = Read-Host "Enter Type of Permission(Author, Editor, Owner, Reviewer, none)" 

$AllFolders = Get-MailboxFolderStatistics $Mailbox | Where { $_.FolderPath.ToLower().StartsWith(“/“) -eq $True }

ForEach($folder in $AllFolders)

{

$foldername = $Mailbox + ":" + $folder.FolderPath.Replace(“/”,”\”)


Add-MailboxFolderPermission $foldername -User $delegate -AccessRights $Permission -confirm:$true

}
;Break}
3 {

$Mailbox = Read-Host "Enter Mailbox ID" 

$delegate = Read-Host "Enter Delegate ID "

$Permission = Read-Host "Enter Type of Permission(Author, Editor, Owner, Reviewer, none)" 

$Default = Get-MailboxFolderStatistics $mailbox | ?{$_.foldertype -ne "user created" -and $_.foldertype -ne "Recoverableitemsroot" -and $_.foldertype -ne "RecoverableItemsDeletions" -and $_.foldertype -ne "RecoverableItemspurges" -and $_.foldertype -ne "RecoverableItemsversions" -and $_.foldertype -ne "syncissues" -and $_.foldertype -ne "conflicts" -and $_.foldertype -ne "localfailures" -and $_.foldertype -ne "serverfailures" -and $_.foldertype -ne "RssSubscription" -and $_.foldertype -ne "JunkEmail" -and $_.foldertype -ne "CommunicatorHistory" -and $_.foldertype -ne "conversationactions"}

ForEach($folder in $default)

{

$foldername = $Mailbox + ":" + $folder.FolderPath.Replace(“/”,”\”)


Add-MailboxFolderPermission $foldername -User $delegate -AccessRights $Permission -confirm:$true


}

;break}

4 {

$Mailbox = Read-Host "Enter Mailbox ID" 

$delegate = Read-Host "Enter Delegate ID "

$Permission = Read-Host "Enter Type of Permission(Author, Editor, Owner, Reviewer, none)" 

$Default = Get-MailboxFolderStatistics $mailbox | ?{$_.foldertype -eq "user created"}

ForEach($folder in $default)

{

$foldername = $Mailbox + ":" + $folder.FolderPath.Replace(“/”,”\”)


Add-MailboxFolderPermission $foldername -User $delegate -AccessRights $Permission -confirm:$true

}

;break}

5 {

}
}
