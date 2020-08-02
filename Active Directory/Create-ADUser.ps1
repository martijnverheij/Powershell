<#
.SYNOPSIS
Creates a user account in active directory with information entered in by the user.
 
.DESCRIPTION
This will create a user in Active Directory automatically with Powershell.
 
.NOTES
Name: AD-CreateUserNoMailbox.ps1
Version: 1.0
Author: Martijn Verheij
Date of last revision: 30/01/2019

#>
 
 
#Checking if the shell is running as administrator.
#Requires -RunAsAdministrator
#Requires -Module ActiveDirectory
$title = "Create a User Account in Active Directory"
 
$host.ui.RawUI.WindowTitle = $title
 
Import-Module ActiveDirectory -EA Stop
 
sleep 5
cls
 
 
Write-Host
Write-Host
#Getting variable for the First Name
$firstname = Read-Host "Voornaam?"
#Getting variable for the Last Name
$lastname = Read-Host "Achternaam?"
#Getting variable for tussenvoegsel
$tussenvoegsel = Read-Host "Tussenvoegsel?"
#Setting Full Name (Display Name) to the users first and last name
$fullname = "$firstname $tussenvoegsel $lastname"
#Write-Host
#Setting username to first initial of first name along with the last name.
$i = 1
$logonname = $lastname + $firstname.substring(0,$i)
#$empID = Read-Host "Enter in the Employee ID"
#Setting the Path for the OU.
$OU = "OU=Omroep Bo,DC=rtvkatwijk,DC=nl"
$domain = "bollenstreekomroep.nl"
#Default Password
$Password = "Welkom@BO!" | ConvertTo-SecureString -AsPlainText -Force
#Get variable for homeadres
$homeadres = Read-Host "Straat & Huisnummer?"
#Get variable for Postcode
$Zipcode = Read-Host "Postcode XXXX XX?"
#Get variable for homeadres
$City = Read-Host "Woonplaats?"
#Get variable for Company
$company = "Bollenstreek Omroep"
#Get variable for Phonenumber
$mobile = Read-Host "Mobile Nummer?"
$State = "Zuid-Holland"
 
 
cls
#Displaying Account information.
Write-Host "======================================="
Write-Host
Write-Host "Voornaam:       $firstname"
Write-Host "Achternaam:     $lastname"
Write-Host "Display naam:   $fullname"
Write-Host "Gebruikersnaam: $logonname"
Write-Host 
Write-Host "Overige Info:"
Write-Host "Adres:                 $homeadres"
Write-Host "Postcode & Woonplaats: $Zipcode $City"
Write-Host "Mobile telefoon:       $mobile"



Write-Host
Read-Host "Press Enter to Continue Creating the Account"
Write-Host "Creating Active Directory user account now" -ForegroundColor:Green
 
#Creating user account with the information you inputted.
New-ADUser -Name $fullname -GivenName $firstname -Surname $lastname -DisplayName $fullname -SamAccountName $logonname -UserPrincipalName $logonname@$domain -City $City -Company $Company -MobilePhone $mobile -PostalCode $Zipcode -StreetAddress $homeadres -State $State -AccountPassword $password -Enabled $true -Path $OU -ChangePasswordAtLogon $True -Confirm:$false
 
sleep 2
 
 
Write-Host
 
$ADProperties = Get-ADUser $logonname -Properties *
 
Sleep 3
 
cls
 
Write-Host "========================================================"
Write-Host "Het medewerkers object is aangemaakt met de volgende eigenschappen"
Write-Host
Write-Host "Voornaam:       $firstname"
Write-Host "Achternaam:     $lastname"
Write-Host "Display naam:   $fullname"
Write-Host "Gebruikersnaam: $logonname@$domain"
Write-Host
Write-Host "Overige Info:"
Write-Host "Adres:                 $homeadres"
Write-Host "Postcode & Woonplaats: $Zipcode $City"
Write-Host "Mobile telefoon:       $mobile"
Write-Host
