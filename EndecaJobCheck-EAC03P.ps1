<#
	Purpose: Check status of a job on a computer and send an email if it is disable
#>
$ComputerName = "1-p-en-eac03p"

# current job that is disable 
$DisableJob = @(" Zone 100 English Parametric Parital Update"
    , "Zone 101 English Parametric Parital Update"
    , "CatalogItemSearch English Parametric Baseline Update"
    , "CatalogItemSearch English Parametric Partial Update"
    , "Sistino English Parametric Baseline Update")

try {
	$schedule = new-object -com("Schedule.Service") 
} catch {
	Write-Warning "Schedule.Service COM Object not found, this script requires this object"
	return
}
$schedule.connect($ComputerName) 
$tasks = $schedule.getfolder("\").gettasks(0)
$results = @()
$tasks | Foreach-Object {
	$PSObject = New-Object PSObject

    # check for the Job name containing "Parametric"
    # the reverse apostrophe is to indicate continuation of line
    if ($_.name.contains("Parametric") `
        -and !($_.Enabled) `
        -and !($DisableJob -match $_.name)
        ) {

	    $PSObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $_.name
	    $PSObject | Add-Member -MemberType NoteProperty -Name 'State' -Value $_.state
	    $PSObject | Add-Member -MemberType NoteProperty -Name 'Enabled' -Value $_.enabled
	    $PSObject | Add-Member -MemberType NoteProperty -Name 'LastRunTime' -Value $_.lastruntime
	    $PSObject | Add-Member -MemberType NoteProperty -Name 'LastTaskResult' -Value $_.lasttaskresult
	    $PSObject | Add-Member -MemberType NoteProperty -Name 'NumberOfMissedRuns' -Value $_.numberofmissedruns
	    $PSObject | Add-Member -MemberType NoteProperty -Name 'NextRunTime' -Value $_.nextruntime
	    $PSObject | Add-Member -MemberType NoteProperty -Name 'UserId' -Value ([regex]::split($_.xml,'<UserId>|</UserId>'))[1]
    	$PSObject
 
         Write-Host "Sending Email"
 
         #SMTP server name
         $smtpServer = "mailserver.address.here"
 
         #Email structure 
         $from = "endeca.disabled.job@art.com"
         $to = "tyuen@art.com"
         $subject = $_.name + " - Disabled"
         $body = "<b>Server:</b>" + $ComputerName
         $body += "<br><b>Window Task Name:</b> " + $_.name
         $body += "<br><b>Enabled:</b> " + $_.Enabled
         $body += "<br><b>Last Run Time:</b> " + $_.LastRunTime
         $body += "<br><b>Action: Please re-enable job.</b>"
 
         #Sending email 
            Send-MailMessage -SmtpServer $smtpServer `
                -To $to `
                -Cc "tyuen@art.com" `
                -From $from `
                -Subject $subject `
                -Body $body `
                -BodyAsHtml

    }
}