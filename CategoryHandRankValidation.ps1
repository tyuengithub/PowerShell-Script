<#
    Purpose: To generate report of item in create status and have been associated to an image
    Created Date: 9/14/2017
    Created By: Tommy Yuen
#>

# import database helper
import-module "D:\Application\Scripts\databaseProcess.ps1"
import-module "D:\Application\Scripts\generalFunction.ps1"

#region helper function
# write output to log file
function writeOutPutToFileNoTimeStamp ($message, $logFile) {
    $message | Out-File $logFile -Append

    return
}


# build the email footer 
function emailFooter {
    $footer += "<br>&nbsp"
    $footer += "<br><font face='verdana,arial,sans-serif' siz='9px'>"
    $footer += "<br>Category Hand Rank Sweeper Program"
    $footer += "<br>&nbsp;<br>"
    $footer += "art.com | allposters.com"
    $footer += "<br>&nbsp;<br>"
    $footer += "If you have received this e-mail in error, please immediately notify the sender by reply e-mail and destroy the original e-mail and its attachments without reading or saving them. This e-mail and any documents, files or previous e-mail messages attached to it, may contain confidential or privileged information that is prohibited from disclosure under confidentiality agreement or applicable law. If you are not the intended recipient, or a person responsible for delivering it to the intended recipient, you are hereby notified that any disclosure, copying, distribution or use of this e-mail or any of the information contained in or attached to this e-mail is STRICTLY PROHIBITED. Thank you."
    $footer += "</font>"
    return $footer
}

#endregion 

# get computer name
$ComputerName = GET-CONTENT env:computername


#region variable declaration
$logFileName = "D:\Logs\CategoryHandRankValidation\CategoryHandRankIssue_" + (GET-DATE -Format yyyMMdd) + '.log'
$server = 'BUILD01'
$database = 'dBuilder_Master'
$tSQLScript = ''
$outputString = ''
$attachFile = "D:\Logs\CategoryHandRankValidation\CategoryHandRankIssue_" + (Get-Date -Format yyyMMddhhmmss) + '.csv'



#SMTP server name
$smtpServer = "mailserver.address.here"
$smtpPort = 25
$from = "category.handrank.sweeper.program@art.com"
$to = "tyuen@art.com"
$cc = "tyuen@art.com"
$subject = "Category Hand Rank Check"
$enableSendEmail = 1
$body = ""
#endregion


#region generating script information
try {

# to redirect output message to a log file, there is a "stop-transacript" at the bottom of the file
START-TRANSCRIPT -append -path $logFileName

}
catch {

# file is locked, closing this file
STOP-TRANSCRIPT 
START-TRANSCRIPT -append -path $logFileName


}





$tSQLScript = "
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Now DATETIME = GETDATE()

-- Get List of Active Hand Rank
SELECT tblCategoryItemRank.*
	, CAST('' AS VARCHAR(500)) ErrorMsg
INTO #tmpList
FROM tblCategoryItemRank (NOLOCK)
WHERE tblCategoryItemRank.EndDate > @Now
	AND CustomerZoneID NOT IN ( 100 )

CREATE CLUSTERED INDEX ix_#tmpList_APNum_CustomerZoneID ON #tmpList (APNum, CustomerZoneID) 

-- Test #1: items not in zone
UPDATE tblCategoryItemRank
SET ErrorMsg = CASE WHEN LEN(ErrorMsg) > 0 THEN ErrorMsg + '|' ELSE ErrorMsg END 
                + 'FAILED: ITEM IN ZONE AVAILABILITY #1: ITEM NOTE IN ZONE, NEED TO ADD ITEM TO ZONE ' 
FROM #tmpList tblCategoryItemRank
	LEFT JOIN tblItemCustomerZone (NOLOCK)
		ON tblItemCustomerZone.APNum = tblCategoryItemRank.APNum
		AND tblItemCustomerZone.CustomerZoneID = tblCategoryItemRank.CustomerZoneID
WHERE tblItemCustomerZone.APNum IS NULL


-- Test #2: items not in zone
UPDATE tblCategoryItemRank
SET ErrorMsg = CASE WHEN LEN(ErrorMsg) > 0 THEN ErrorMsg + '|' ELSE ErrorMsg END 
                + 'FAILED: ITEM IN ZONE AVAILABILITY #2: ITEM IN ZONE, BUT NOT IN AVAILABLE STATUS IN ZONE '
FROM #tmpList tblCategoryItemRank
	LEFT JOIN tblItemCustomerZone (NOLOCK)
		ON tblItemCustomerZone.APNum = tblCategoryItemRank.APNum
		AND tblItemCustomerZone.CustomerZoneID = tblCategoryItemRank.CustomerZoneID
		AND tblItemCustomerZone.Disabled = 0
		AND tblItemCustomerZone.ItemCustomerZoneStatusID = 2
WHERE tblItemCustomerZone.APNum IS NULL


-- Test #3: Check for duplicate ranking position
UPDATE tblCategoryItemRank
SET ErrorMsg = CASE WHEN LEN(ErrorMsg) > 0 THEN ErrorMsg + '|' ELSE ErrorMsg END 
                + 'FAILED: MULTIPLE ITEM RANKED IN SAME POSITION IN CATEGORY: UPDATE THE RANK OF ONE OF THE ITEM '
FROM #tmpList tblCategoryItemRank
	INNER JOIN (
		SELECT CustomerZoneID, CategoryID, Position, COUNT(1) AS dupTotal
		FROM #tmpList inner_temp
		GROUP BY CustomerZoneID, CategoryID, Position
		HAVING COUNT(1) > 1
	) dup ON dup.CustomerZoneID = tblCategoryItemRank.CustomerZoneID
		AND dup.CategoryID = tblCategoryItemRank.CategoryID
		AND dup.Position = tblCategoryItemRank.Position

-- Test #3: Check for duplicate ranking position
UPDATE tblCategoryItemRank
SET ErrorMsg = CASE WHEN LEN(ErrorMsg) > 0 THEN ErrorMsg + '|' ELSE ErrorMsg END 
                + 'FAILED: ITEM RANK MULTIPLE TIME IN SAME CATEGORY: REMOVE ONE OF THE RANK FOR THE ITEM'
FROM #tmpList tblCategoryItemRank
	INNER JOIN (
		SELECT CustomerZoneID, CategoryID, APNum, COUNT(1) AS dupTotal
		FROM #tmpList tblCategoryItemRank
		GROUP BY CustomerZoneID, CategoryID, APNum
		HAVING COUNT(1) > 1
	) dup ON dup.CustomerZoneID = tblCategoryItemRank.CustomerZoneID
		AND dup.CategoryID = tblCategoryItemRank.CategoryID
		AND dup.APNum = tblCategoryItemRank.APNum


SELECT DISTINCT CustomerZoneID, CategoryID, APNum, Position, StartDate, EndDate, ErrorMsg
FROM #tmpList
WHERE LEN(errormsg) > 0
ORDER BY CustomerZoneID, CategoryID, Position

"


#$returnData = selectQuery -query $tSQLScript -serverName $server -databaseName $database

$returnData = selectQuery -query $tSQLScript -serverName $server -databaseName $database

$numOfRewords = $returnData.Count

$emailBody = "<html><head>"
$emailBody += "<style type=""text/css"">.btmenuheader {font-family:Verdana; font-size:12px;font-weight:bold;}"
$emailBody += " .btmenuitem {font-family:Verdana; font-size:10px;font-weight:normal;}"

$emailBody += "</style></head>"
$emailBody += "<h2>Running from Server: $ComputerName </h2>"
$emailBody += "<h2># items with hand rank issue: $numOfRewords </h2>"
$emailBody += "<b><font color='red'>Please fix the data.  </font></b><br /><br />"

$outputString = "CustomerZoneID|CategoryID|APNum|Position|StartDate|EndDate|ErrorMsg"

writeOutPutToFileNoTimeStamp -message $outputString -logFile $attachFile

WRITE-OUTPUT ((GET-DATE -format('MM/dd/yyyy hh:mm:ss tt ')) + "Generating email. . . `r")

# loop through data table to get information
FOREACH ($datarow in $returnData) {


    $outputString = ''
    $outputString += $datarow['CustomerZoneID'].ToString() + '|'
    $outputString += $datarow['CategoryID'].ToString() + '|'
    $outputString += $datarow['APNum'].ToString() + '|'
    $outputString += $datarow['Position'].ToString() + '|'
    $outputString += $datarow['StartDate'].ToString() + '|'
    $outputString += $datarow['EndDate'].ToString() + '|'
    $outputString += $datarow['ErrorMsg'].ToString() 

#    write-output ((get-date -format('MM/dd/yyyy hh:mm:ss tt ')) + "APNum: " + $APNum + "`r")

    writeOutPutToFileNoTimeStamp -message $outputString -logFile $attachFile

}


    writeOutPutToFileNoTimeStamp -message $outputString -logFile $attachFile

    $emailBody += emailFooter



WRITE-OUTPUT ((GET-DATE -format('MM/dd/yyyy hh:mm:ss tt ')) + "Sending email. . . `r")

# WRITE-HOST $outputString
sendEmail -fromAddress $from `
        -toAddress $to `
        -emailSubject $subject `
        -emailBody $emailBody `
        -SMTPServer $smtpServer `
        -SMTPPort $smtpPort `
        -file $attachFile `
        -ccAddress $cc


# stop logging output
STOP-TRANSCRIPT 

