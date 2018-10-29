<#

Create Date: 9/15/2017
Created By: Tommy Yuen
Purpose: The script will
    1) To download rating and review zip files from PowerReview ftp site
    2) extract the zip file
    3) copy to the network folder
#>

#< variable declaration #>
$url = "ftp://partners.powerreviews.com"
$user = "login" 
$pass = "password" 
$logName = "D:\Logs\PowerReviews\ftpdownload_" + (Get-Date -Format "yyyMMddHHmmss") + ".log"
$targetfolder = "D:\Reviews"


# for listing files in directory on ftp site
$credentials = new-object System.Net.NetworkCredential($user, $pass) 

# for downloading files on ftp site
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  


# function to list files in directory of ftp site
function Get-FtpDir ($url) {
    $request = [Net.WebRequest]::Create($url)
    $request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
    if ($credentials) { $request.Credentials = $credentials }
    $response = $request.GetResponse()
    $reader = New-Object IO.StreamReader $response.GetResponseStream() 
	$reader.ReadToEnd()
	$reader.Close()
	$response.Close()

    return
}

# function to remove files in directory of ftp site
function Remove-FTPItem ($FTPSite, $RemoveItem) {
    $sourceuri = $FTPSite + "/" + $RemoveItem
    $ftprequest = [System.Net.FtpWebRequest]::create($sourceuri)
    $ftprequest.Credentials =  New-Object System.Net.NetworkCredential($user,$pass)
    $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $itemremoveoutput = $ftprequest.GetResponse()

    return
}

# write output to log file
function writeOutPutToFile ($message, $logFile) {
    "`n " + (Get-Date -Format g) + ": " + $message | Out-File $logFile -Append

    return
}


#write-host $files
# Main Code Begin here
# to get a few logging information, and stop the output immediately as extracing file will be huge
# start-transcript -append -path $logName


# stop redirect output message log file
# stop-transcript


# write to log
writeOutPutToFile "Log file: " $logName



# write to log
writeOutPutToFile "Connecting to $url" $logName

# write to log
writeOutPutToFile "username: $user" $logName


# Get list of files in directory
$files = Get-FTPDir $url | Out-String

<# string clean up, to split the return data in array like structure #>
$files = $files -replace "zip","zip,"
$files = $files -replace "txt","txt,"


# removing the carriage return and linefeed
$files = $files -replace "`n",""
$files = $files -replace "`r",""
$files = $files -replace " ",""

# create the string into array to loop
$files = $files -split ","


# write to log
writeOutPutToFile "Looking for done_prod.txt signal file to initate download for ART_prod.zip " $logName
writeOutPutToFile "Looking for done_apc.txt signal file to initate download for APC_prod.zip " $logName


$unzipFile = 0
$brandID = 0
$copyFiles = 0
$unzipFileList = @()



# loop through the return list
Foreach ($file in ($files -like "*.txt")){

    $InitiateDownload = 0
    $zipFileSource = ""
    $zipFileTarget = ""

    # write to log
    writeOutPutToFile ("File on ftp site: " + $file) $logName


    if ($file -like "done_prod.txt") {
        # setup filename to download
	    $zipFileSource = $url + "/zipfilename.zip" 

        # setup local folder and file name
        $zipFileTarget = $targetfolder + "\zipfilename.zip"

        $InitiateDownload = 1
        $brandID = 2
    }

    if ($file -like "signalFile.txt") {
        # setup filename to download
	    $zipFileSource = $url + "/zipfilename.zip" 

        # setup local folder and file name
        $zipFileTarget = $targetfolder + "\zipfilename.zip"

        $InitiateDownload = 1
        $brandID = 1

    }


    if ($InitiateDownload -eq 1) {


        # write to log
        writeOutPutToFile "Signal file $file found on the ftp site, initiate download review files" $logName
        writeOutPutToFile "Download zip file: $zipFileSource"  $logName

        write-host "source: " $zipFileSource
        write-host "target: " $zipFileTarget

        # download the file on ftp site
	    $webclient.DownloadFile($zipFileSource, $zipFileTarget)

        writeOutPutToFile "Downloading $zipFileSource completed! " $logName


        writeOutPutToFile "Removing $file  signal file from ftp site! " $logName


        # remove the signal file after downloading the zip file
        Remove-FTPItem $url $file 


        $unzipFileList += $zipFileTarget
    }

}

# closing ftp connection
writeOutPutToFile "closing ftp connection to $url" $logName



<#
    unzip files


#>

for ($i = 0; ($i -le $unzipFileList.Count - 1) -and ($InitiateDownload -eq 1) ; $i++) {


    $zipFileTarget = $unzipFileList[$i].ToString().ToLower()

    # unzip the zip file using the 3rd party zip software
    # '&' symbol is Powershell to invoke app
    # 'x' is 7-zip means to extract

    if ($zipFileTarget -match "apc_prod.zip") {

        writeOutPutToFile ("Extracting file " + $zipFileTarget) $logName

        & "C:\Program Files\7-Zip\7z.exe" x $zipFileTarget -oD:\Reviews\Prod\APC\Active -r -aoa

        writeOutPutToFile "Extract file completed! " $logName

    }

    if ($zipFileTarget -match "art_prod.zip") {

        writeOutPutToFile ("Extracting file " + $zipFileTarget) $logName

        & "C:\Program Files\7-Zip\7z.exe" x $zipFileTarget -oD:\Reviews\Prod\ART\Active -r -aoa

        writeOutPutToFile "Extract file completed! " $logName
    }


}


<#
    Copy files
#>
for ($i = 0; ($i -le $unzipFileList.Count - 1) -and ($InitiateDownload -eq 1) ; $i++) {

    writeOutPutToFile "Copying file to network folder" $logName

    $zipFileTarget = $unzipFileList[$i].ToString().ToLower()


	# first file
    if ($zipFileTarget -match "zipfilename_1.zip") {
        writeOutPutToFile "Copying file to \\network_folder\" $logName

        Copy-Item -Force -Recurse -Path D:\Reviews\files \\network_folder\

        writeOutPutToFile "Complete copying file \\network_folder\" $logName
    }

	# second file
    if ($zipFileTarget -match "zipfilename_2.zip") {

        writeOutPutToFile "Copying file to \\network_folder\" $logName

        Copy-Item -Force -Recurse -Path D:\Reviews\files \\network_folder\

        writeOutPutToFile "Complete copying file \\network_folder\" $logName

    }
}


<#

Insert into database . . .
to do

#>

