<#
    Purpose: General function
    Date: 3/1/2016

#>

function checkSignalFile {

    #Vars for Server and JobName
    param([string]$endecaIndex, [string]$signalFile, [string]$fullBuildTime)

    # check on how long the full build signal file was generated
    if (((Get-Date) - (Get-ChildItem $signalFile).LastWriteTime).TotalMinutes -gt $fullBuildTime) {
         write-output ((get-date -format('MM/dd/yyyy hh:mm:ss tt ')) + "CHECK ON THE ENDECA BUILD FOR $endecaIndex, POSSIBLE STUCK `r")

         write-output ((get-date -format('MM/dd/yyyy hh:mm:ss tt ')) + "Sending Email to notify team for $endecaIndex `r")
         sendEmail -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime
 
    }

}

function sendEmail {

    #Vars for Server and JobName
    param([string]$endecaIndex, [string]$signalFile, [string]$fullBuildTime)

    #SMTP server name
    $smtpServer = "sacrelay.art.com"
 
    #Email structure 
    $from = "price.migration.job@art.com"
    $to = "teamneo@art.com"
    $subject = "Price Migration: $endecaIndex "
	$body = "<b>Alert Generated From: </b>" + $env:COMPUTERNAME
    $body += "<br><b>Endeca Full Build Signal File:</b> $signalFile"
    $body += "<br><b>Build Started:</b> <font color='red'>" + (Get-ChildItem $signalFile).LastWriteTime + "</font>"
    $body += "<br><b>Expected Build Finish:</b> $fullBuildTime minutes"
    $body += "<br><b>Comment:</b> Running longer than usual.  Check build for failure"
 
    #Sending email 
    Send-MailMessage -SmtpServer $smtpServer `
        -To $to `
        -Cc "pe@art.com" `
        -From $from `
        -Subject $subject `
        -Body $body `
        -BodyAsHtml

}


# sending email
function sendEmail ($fromAddress, $toAddress, $ccAddress, $emailSubject, $emailBody, $SMTPServer, $SMTPPort, $enableSSL, $userName, $password, $file) {
    #Sending email 
    $message = New-Object System.Net.Mail.MailMessage
    $message.subject = $emailsubject
    $message.body = $emailbody
    $message.to.add($toaddress)
    $message.cc.Add($ccAddress)
    $message.from = $fromAddress
    $message.IsBodyHTML = $true

    $attachment = New-Object System.Net.Mail.Attachment($file)

    $message.Attachments.Add($attachment)
 

    $smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);

    if ($enableSSL -eq $true) {
        $smtp.EnableSSL = $true
        $smtp.Credentials = New-Object System.Net.NetworkCredential($userName, $password);
    }

    $smtp.Send($message);

}


# write output to log file
function writeOutPutToFile ($message, $logFile) {
    (Get-Date -Format g) + ": " + $message | Out-File $logFile -Append

    return
}

