#
# Script.ps1
#

# Run as administrator, in case it's not (testing purposes)
# if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Variables
$version = "1.2"
$normalReplicationStatus = "Normal"
$temporaryFilePath = $env:TEMP + "\VMs Info.csv"
$lastExecutionInfoFilePath = $PSScriptRoot + "\LastExecutionReturnCode"
$emailSmtpServer = "smtp.office365.com"
$emailSmtpServerPort = "587"
$emailSmtpUser = "example@example.com"
$emailSmtpPass = "password"
$emailToBeUsed = "example@example.com"

$lastExecutionInfo =  "0"

if(Test-Path $lastExecutionInfoFilePath)
{
    $lastExecutionInfo = Get-Content $lastExecutionInfoFilePath
    Clear-Content $lastExecutionInfoFilePath
}

# Header
Write-Host @"
     #############################################################
     #                                                           #
     #   Virtual Machines Replication Health Notifier  (VMRHN)   #
     #                   by  github.com/schdck                   #
     #                        Script v$version                        #
     #                                                           #
     #############################################################

"@

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	Write-Host "You must be and administrator in order to run this script.`nShutting down script..."
	"-1" >> $lastExecutionInfoFilePath
    exit -1
}

if((Get-VMReplication | WHERE { $_.Health -ne $normalReplicationStatus }).Count -eq 0)
{
    Write-Host "Yup, all good. All VMs are normally replicating.`nShutting down script..."
	"0" >> $lastExecutionInfoFilePath
    exit 0
}

if($lastExecutionInfo -eq "1")
{
	"1" >> $lastExecutionInfoFilePath
    exit 1
}

Write-Host "Retrieving and saving VMs status..."
Get-VMReplication | select Name, Health, Mode, PrimaryServer, ReplicaServer, ReplicaPort, AuthType | export-csv $temporaryFilePath -Encoding ascii -NoTypeInformation -delimiter ";"

Write-Host "Sending email..."

$attachment = New-Object System.Net.Mail.Attachment($temporaryFilePath)
$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.Attachments.Add($attachment)
$emailMessage.From = $emailToBeUsed

# ?? CHANGE ME ??
$emailMessage.To.Add( "[EMAIL]" ) # Copy and past this line to add more email recipients
$emailMessage.Subject = "ALERT: The replication of one or more VMs failed" 
$emailMessage.IsBodyHtml = $true
$emailMessage.Body = @"
<h2>ALERT</h2>

<p>The replication of one or more VMs failed.</p>

<p>Information about the health state of the replicas are attached to this e-mail.</p>

<p>This email was automatically sent.</p>

<p><i>Virtual Machines Replication Health Notifier (VMRHN) v$version by github.com/schdck</i></p>
"@
 
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
$SMTPClient.Send( $emailMessage )

Write-Host "Done!`nShutting down script..."

"1" >> $lastExecutionInfoFilePath

# Wait for user  (testing purposes)
# $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

exit 1