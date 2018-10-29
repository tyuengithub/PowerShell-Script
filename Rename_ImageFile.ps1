param ([string]$imageFilePath, [string]$uploadSheetFile)

<#
    Purpose: the script will rename the filename of the image to be "PubNum.jpg"
		- the file need to have a column call "pubnum"
    Create Date: 6/19/2017
    Created By: Tommy Yuen
	Command: powershell -f rename_imagefile.ps1 -imageFilePath c:\imagelocation -uploadSheetFile c:\temp\pubnumlist.csv

#>


# list of pubnum from upload sheet
$fileDataList = import-csv $uploadSheetFile


# loop through the network path
get-childitem  $imageFilePath | ForEach-Object {
    $fileName = $_.FullName

    # for each file in the network path, check to see if it matches the pub num
    foreach ($itemrow in $fileDataList) {

        # if the pubnum matches, then it will rename it to pubnum.jpg
        if ($fileName -match $file.PubNum ) {

            $newFileName = $itemrow.PubNum + '.jpg'

            write-host "pubnum: " $itemrow.PubNum
            write-host 'current: ' $fileName 
            write-host 'new: ' "$imageFilePath\$newFileName"

            Rename-Item $fileName "$imageFilePath\$newFileName"
        }

    }

}