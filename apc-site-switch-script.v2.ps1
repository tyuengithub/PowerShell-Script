<#
    The script will use .NET Framework to connect to database with Powershell script to check for site switch status
#>

<# Region: Function #>
# build the email footer 
function emailFooter {
    $footer += "<br>&nbsp"
    $footer += "<br><font face='verdana,arial,sans-serif' siz='9px'>Regards,"
    $footer += "<br>Site Switcher Team"
    $footer += "<br>art.com"
    $footer += "<br>Phone: "
    $footer += "<br>&nbsp;<br>"
    $footer += "art.com inc.<br>"
    $footer += "art.com  | allposters.com | artistrising.com | posterrevolution.com"
    $footer += "<br>&nbsp;<br>"
    $footer += "If you have received this e-mail in error, please immediately notify the sender by reply e-mail and destroy the original e-mail and its attachments without reading or saving them. This e-mail and any documents, files or previous e-mail messages attached to it, may contain confidential or privileged information that is prohibited from disclosure under confidentiality agreement or applicable law. If you are not the intended recipient, or a person responsible for delivering it to the intended recipient, you are hereby notified that any disclosure, copying, distribution or use of this e-mail or any of the information contained in or attached to this e-mail is STRICTLY PROHIBITED. Thank you."
    $footer += "</font>"
    return $footer
}

# build site switch successful email
function buildsuccessfulemail ($dsitez01status, $dsitez02status, $switchdate) {
        $buildsiteswitchemail = "<font face='verdana,arial,sans-serif' siz='9px'>Hi All, "
        $buildsiteswitchemail += "<br>&nbsp;<br>"
        $buildsiteswitchemail += "Site switch is complete. "
        $buildsiteswitchemail += "</font>"
        $buildsiteswitchemail += "<br>&nbsp"
        $buildsiteswitchemail += "<table border='1' cellpadding='0'>"
        $buildsiteswitchemail += "<tr>"
        $buildsiteswitchemail += "<td><b><font face='verdana,arial,sans-serif' siz='9px'>Site Switch Date</font></b></td>"
        $buildsiteswitchemail += "<td><b><font face='verdana,arial,sans-serif' siz='9px'>1SDB-DSITEZ01</font></b></td>"
        $buildsiteswitchemail += "<td><b><font face='verdana,arial,sans-serif' siz='9px'>1SDB-DSITEZ03</font></b></td>"
        $buildsiteswitchemail += "</tr>"
        $buildsiteswitchemail += "<tr align='right'><td><font face='verdana,arial,sans-serif'>" + $switchdate + "</font></td>"
        $buildsiteswitchemail += "  <td><font face='verdana,arial,sans-serif'>" + $dsitez01status + "</font></td>"
        $buildsiteswitchemail += "  <td><font face='verdana,arial,sans-serif'>" + $dsitez02status + "</font></td>"
        $buildsiteswitchemail += "  </tr>"
        $buildsiteswitchemail += "</table>"
        $buildsiteswitchemail += emailFooter

    return $buildsiteswitchemail
}

# build review site build job email
function buildReviewSiteBuildJobEmail {
    $reviewJobEmail = "<font face='verdana,arial,sans-serif' siz='9px'>"
    $reviewJobEmail += "Site build job on BUILD01 did not finish.  Check for failed job."
    $reviewJobEmail += "<br>•	dSite Build: 1 - ACE Production Push dBuilderMaster"
    $reviewJobEmail += "<br>•	dSite Build: 1b - Build and Migrate tblCategoryImageExpanded"
    $reviewJobEmail += "<br>•	dSite Build: 2a - Zone 1 Category Index Build"
    $reviewJobEmail += "<br>•	dSite Build: 2b - Zone 2 Category Index Build"
    $reviewJobEmail += "<br>•	dSite Build: 3a - dSite_Z1 BackUp and restore"
    $reviewJobEmail += "<br>•	dSite Build: 3b - dSite_Z2 BackUp and restore"
    $reviewJobEmail += "<br>•	dSite Build: 4a - 1SDB-DSITEZ01 DSite_Z1 Build"
    $reviewJobEmail += "<br>•	dSite Build: 4b - 1SDB-DSITEZ01 DSite_Z2 Build"
    $reviewJobEmail += "<br>•	dSite Build: 6a - 1SDB-DSITEZ03 DSite_Z1 Build"
    $reviewJobEmail += "<br>•	dSite Build: 6b - 1SDB-DSITEZ03 DSite_Z2 Build"
    $reviewJobEmail += "</font>"
    $reviewJobEmail += emailFooter

    return $reviewJobEmail
}


# sending email
function sendEmail ($fromAddress, $toAddress, $emailSubject, $emailBody, $SMTPServer, $SMTPPort, $enableSSL, $userName, $password) {
    #Sending email 
    $message = New-Object System.Net.Mail.MailMessage
    $message.subject = $emailsubject
    $message.body = $emailbody
    $message.to.add($toaddress)
    $message.from = $fromAddress
    $message.IsBodyHTML = $true
 

    $smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);

    if ($enableSSL -eq $true) {
        $smtp.EnableSSL = $true
        $smtp.Credentials = New-Object System.Net.NetworkCredential($userName, $password);
    }

    $smtp.Send($message);

}


# open select statement to retreive data into data table
function selectQuery ($serverName, $databaseName, $username, $password, $query) {
    # setup database connection parameter
    $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter

    $connString = "Server=$serverName;Database=$databaseName;user id=$username;password=$password"
    $dataAdapter.SelectCommand = new-object System.Data.SqlClient.SqlCommand ($query,$connString)
    $commandBuilder = new-object System.Data.SqlClient.SqlCommandBuilder $dataAdapter
    $dt = New-Object System.Data.DataTable
    [void]$dataAdapter.fill($dt)

    return $dt
}
<# End Region: Function #>



# getting time
$Now = Get-Date

#SMTP server name
$smtpServer = "mailserver.address.here"
$smtpPort = 25
$from = "site.switch.processor@art.com"
$to = "tyuen@art.com"
$subject = "APC Site Switch: "
$enableSendEmail = 1
$body = ""

# get computer name
$ComputerName = Get-Content env:computername

# database information
$serverName = "BUILD01"
$databaseName = "dBuilder_Master"
$userName = "username" 
$password = 'password'

# query script
$query = "SELECT TOP 1 CONVERT(VARCHAR(12), GETDATE(), 110) AS SwitchDate
    , SiteSwitchSwapHistoryID
    , SiteReplicationStatusID
    , active.DBServer AS CurrentActive
    , tobeactive.DBServer AS PendingActive
    , CASE WHEN tblSiteSwitchSwapHistory.SiteReplicationStatusID = 3 
        AND CONVERT(VARCHAR(12), tblSiteSwitchSwapHistory.SwitchDate, 110) = CONVERT(VARCHAR(12), GETDATE(), 110) THEN 1
      ELSE 0
      END SwitchCompletedForToday
FROM tblSiteSwitchSwapHistory (NOLOCK)
	INNER JOIN tbldSITEConfig active (NOLOCK)
		ON active.GroupID = tblSiteSwitchSwapHistory.ActiveSwitchGroupID
	INNER JOIN tbldSITEConfig tobeactive (NOLOCK)
		ON tobeactive.GroupID = tblSiteSwitchSwapHistory.ReplSwitchGroupID
WHERE active.IsActive = 1
	AND active.GroupID IN (1, 2)
	AND tobeactive.IsActive = 1
	AND tobeactive.GroupID IN (1, 2)
ORDER BY tblSiteSwitchSwapHistory.SiteSwitchSwapHistoryID DESC
"

# get data from database
$returnData = selectQuery -serverName $serverName -databaseName $databaseName -username $userName -password $password -query $query

# loop through data table to get information
foreach ($datarow in $returnData) {

    # output for troubleshooting
    Write-Host "SwitchDate: " $datarow['SwitchDate']
    Write-Host "SiteSwitchSwapHistoryID:" $datarow['SiteSwitchSwapHistoryID']
    Write-Host "SiteReplicationStatusID:" $datarow['SiteReplicationStatusID']
    Write-Host "CurrentActive:" $datarow['CurrentActive']
    Write-Host "PendingActive:" $datarow['PendingActive']
    Write-Host "SwitchCompletedForToday: " $datarow['SwitchCompletedForToday']

    $body = "<font face='verdana,arial,sans-serif' siz='9px'><b>Server: " + $ComputerName + "</b></font><br><br>"

    if ( $datarow['SiteReplicationStatusID'] -eq 1) {

        write-host "Ready for site switch"

        # only run the site switch program from 2 pm to 4 pm
        if ( $Now.Hour -eq 14 -or $Now.Hour -eq 15 -or $Now.Hour -eq 16) {

            write-host "Running for site switch"
            $subject += "Starting site switch"
            $body += "<br><font face='verdana,arial,sans-serif' siz='9px'><b>Status: Running for site switch</b></font>"
            $body += emailFooter


            # Send the email about starting to site switch before running the site switch
            sendEmail -fromAddress $from -toAddress $to -emailSubject $subject -emailBody $body -SMTPServer $smtpServer -SMTPPort $smtpPort

            # run site switch
            & D:\Application\SACAPCSiteSwitch\APCSiteSwitcher.exe
            
            
            # send complete site switch email
            # Current Active will become dormant after switch
            $dsitez01 = if ($datarow['CurrentActive'].Contains("1SDB-DSITEZ01")) { "Dormant" } else {"Active"}

            # Pending dormant will become active after switch
            $dsitez03 = if ($datarow['PendingActive'].Contains("1SDB-DSITEZ01")) { "Dormant" } else {"Active"}

            $subject = "APC Site Switch Notification: " + $datarow['SwitchDate']

            # adding the parameter name to increase readability
            $body = buildsuccessfulemail -dsitez01status $dsitez01 -dsitez02status $dsitez03 -switchdate $datarow['SwitchDate']
            
            # site switch complete, send to this group
            $to = "peonsite@art.com"
            
        }
        else {
        
            # site build is ready, but not in the window to run site switch
            write-host "waiting to run switch"
            $subject += "Waiting to run switch"
            $body += "<br><font face='verdana,arial,sans-serif' siz='9px'><b>Status: Site Build Completed.  Pending to run site switch</b></font>"
            $body += emailFooter


        }
    }
    elseif ($datarow['SiteReplicationStatusID'] -eq 2) {
        write-host "Site-switch in progress"
        $subject += "In Progress"
        $body += "<font face='verdana,arial,sans-serif' siz='9px'><b>Status: Site-switch in progress</b></font>"
        $body += emailFooter
    }   
    elseif ($datarow['SiteReplicationStatusID'] -eq 3) {
        write-host "Site-switch Completed"
        $subject += "Site-switch has ran for today."
        $body += "<font face='verdana,arial,sans-serif' siz='9px'><b>Status: Site-switch has ran for today</b></font>"
        $body += emailFooter
    }   
  
    else {
        write-host "Site build job on DB10 did not finish"
        $subject += "Database Job Have Not Completed"
        $body += buildReviewSiteBuildJobEmail 
    }


}

# send email out
if ($enableSendEmail -eq 1) {
    sendEmail -fromAddress $from -toAddress $to -emailSubject $subject -emailBody $body -SMTPServer $smtpServer -SMTPPort $smtpPort
}


