#############################################################################
# Set-Exchange2010Prereqs.ps1
# Configures the necessary prerequisites to install Exchange 2010 on a
# Windows Server 2008 R2 server
#
# Pat Richard, MVP
# http://ucblogs.net/blogs/exchange
#
# 1.0 – Original script 11/27/09 based on the work of Anderson Patricio and
# Bhargav Shukla
#
# Dedicated blog post:
# http://www.ucblogs.net/blogs/exchange/archive/2009/12/12/Automated-prerequisite-installation-via-PowerShell-for-Exchange-Server-2010-on-Windows-Server-2008-R2.aspx
#
# Some info taken from
# http://msmvps.com/blogs/andersonpatricio/archive/2009/11/13/installing-exchange-server-2010-pre-requisites-on-windows-server-2008-r2.aspx
# http://www.bhargavs.com/index.php/powershell/2009/11/script-to-install-exchange-2010-pre-requisites-for-windows-server-2008-r2/
#############################################################################
 
# Detect correct OS here and exit if no match
if (-not((Get-WMIObject win32_OperatingSystem).OSArchitecture -eq '64-bit') -and (Get-WMIObject win32_OperatingSystem).Version -eq '6.1.7600'){
	Write-Host "This script requires a 64bit version of Windows Server 2008 R2, which this is not." -ForegroundColor Red -BackgroundColor Black
	Exit
}
 
Function InstallFilterPack(){
# future: look and see if it's already installed
# 			via registry HKLM:\Software\Microsoft\CurrentVersion\Uninstall\{95120000-2000-0409-1000-0000000FF1CE}
	trap {
		Write-Host "Problem downloading FilterPackx64.exe. Please visit http://tinyurl.com/36yrlj"
		break
	}
	#set a var for the folder you are looking for
	$folderPath = 'C:\Temp'
 
	#Check if folder exists, if not, create it
	if (Test-Path $folderpath){
		Write-Host "The folder $folderPath exists."
	} else{
		Write-Host "The folder $folderPath does not exist, creating..." -NoNewline
		New-Item $folderpath -type directory | Out-Null
		Write-Host "done!" -ForegroundColor Green
	}
 
	# Check if file exists, if not, download it
	$file = $folderPath+"\FilterPackx64.exe"
	if (Test-Path $file){
		write-host "The file $file exists."
	} else {
		#Download Microsoft Filter Pack
		Write-Host "Downloading Microsoft Filter Pack..." -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "http://download.microsoft.com/download/b/e/6/be61cfa4-b59e-4f26-a641-5dbf906dee24/FilterPackx64.exe"
		$clnt.DownloadFile($url,$file)
		Write-Host "done!" -ForegroundColor Green
	}
	#Install Microsoft Filter Pack
	Write-Host "Installing Microsoft Filter Pack..." -nonewline
	$expression = $folderPath+"\FilterPackx64.exe /quiet /norestart"
	Invoke-Expression $expression
	Start-Sleep -Seconds 10
	write-host "done!" -ForegroundColor Green
}
 
Function SetRunOnce(){
	# Sets the NetTCPPortSharing service for automatic startup before the first reboot
	# by using the old RunOnce registry key (because the service doesn't yet exist, or we could
	# use 'Set-Service')
	$hostname = hostname
	$RunOnceCommand = "sc \\$hostname config NetTcpPortSharing start= auto"
	if (Get-ItemProperty -Name "NetTCPPortSharing" -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -ErrorAction SilentlyContinue) {
	    	Write-host "Registry key HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\NetTCPPortSharing already exists." -ForegroundColor yellow
        	Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand | Out-Null
	} else {
	    	New-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand -PropertyType "String" | Out-Null
	}
}
 
Import-Module ServerManager
$opt = "None"
# Do {
	clear
	if ($opt -ne "None") {write-host "Last command: "$opt -foregroundcolor Yellow}
	write-host
	write-host Exchange Server 2010 - Prerequisites script
	write-host Please, select which role you are going to install..
	write-host
	write-host '1) Hub Transport'
	write-host '2) Client Access Server'
	write-host '3) Mailbox'
	write-host '4) Unified Messaging'
	write-host '5) Edge Transport'
	write-host '6) Typical (CAS/HUB/Mailbox)'
	write-host '7) Client Access and Hub Transport'
	write-host
	write-host '9) Configure NetTCP Port Sharing service'
	write-host '   Required for the Client Access Server role' -foregroundcolor yellow
	write-host '   Automatically set for options 2,6, and 7' -foregroundcolor yellow
	write-host '10) Install 2007 Office System Converter: Microsoft Filter Pack'
	write-host '    Required if installing Hub Transport or Mailbox Server roles' -foregroundcolor yellow
	write-host '    Automatically set for options 1, 3, 6, and 7' -foregroundcolor yellow
	write-host
	write-host '13) Restart the Server'
	write-host '14) End'
	write-host
	$opt = Read-Host "Select an option.. [1-14]? "
 
	switch ($opt)    {
		1 { InstallFilterPack; Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server -restart }
		2 { SetRunOnce; Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,NET-HTTP-Activation,RPC-Over-HTTP-Proxy -restart }
		3 { InstallFilterPack; Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server -restart }
		4 { Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Desktop-Experience -restart }
		5 { Add-WindowsFeature NET-Framework,RSAT-ADDS,ADLDS -restart }
		6 { SetRunOnce; InstallFilterPack; Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,NET-HTTP-Activation,RPC-Over-HTTP-Proxy -restart }
		7 { SetRunOnce; InstallFilterPack; Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,NET-HTTP-Activation,RPC-Over-HTTP-Proxy -restart }
		9 { Set-Service NetTcpPortSharing -StartupType Automatic }
		10 {
			# future - auto detect Internet access
			write-host 'Can this server access the Internet?'
			$filtpack = read-host 'Please type (Y)es or (N)o...'
			switch ($filtpack)				{
				Y {InstallFilterPack}
				N {Write-warning 'Please download and install Microsoft Filter Pack from here: http://tinyurl.com/36yrlj'}
			}
		}
		13 { Restart-Computer }
		14 {write-host "Exiting..."}
		default {write-host "You haven't selected any of the available options. "}
	}
# }
# while ($opt -ne 14)