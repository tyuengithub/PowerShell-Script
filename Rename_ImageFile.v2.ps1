<#
    Purpose: the script will rename 
        - ".jpeg" to ".jpg"
        - based on list of pubNum, will rename the file
        - for file with white space, will remove them

    Create Date: 6/21/2017
    Created By: Tommy Yuen

#>




<#

     Section for the info of image path, pubNum list, to indicate whether filename has space

#>

# file path of the images on the network
$imageFilePath = 'c:\temp'

# where is the list of pubnum, NOT REQUIRE if vendor is CID, can leave the file as it is
$pubNumList = 'c:\temp\a.csv'


# "$" need to be infront of true or false
# $true or $false
$renameByPubNumList = $true




<#

     Code to rename filename

#>


# rename image filename based on the provide pubnum list 
if ($renameByPubNumList) {

    # list of pubnum from upload sheet
    $fileList = import-csv $pubNumList

    write-host "folder: $imageFilePath"

    # loop through the files on the network path
    get-childitem  $imageFilePath | ForEach-Object {
        $fileName = $_.FullName

        # for each file in the network path, check to see if the filename matches the pubNum
        foreach ($file in $fileList) {

            # if the pubnum matches, then it will rename it to pubnum.jpg
            if ($fileName -match $file.PubNum ) {

                $newFileName = $file.PubNum + '.jpg'

                write-host 'current: ' $fileName 
                write-host 'new: ' "$imageFilePath\$newFileName"
                write-host ""


                Rename-Item $fileName "$imageFilePath\$newFileName"
            }

        }

    }
}


# the code will strip off anything after finding first 'hyphen' or 'space' of the image filename
# the code is expect the first 'hyphen' is due name of the server
else {
    # loop through the files on the network path

    write-host "folder: $imageFilePath"
    get-childitem  $imageFilePath | ForEach-Object {
        $fileName = Split-Path -Leaf $_.FullName 

        $path = Split-Path -parent $_.FullName 

        # split by hyphen
        $splitFileName = $fileName -split '-'

        $newFileName = $splitFileName[0]

        $newFileName = $newFileName  + '.jpg'    
        $newFileName = $newFileName -REPLACE '.jpg.jpg', '.jpg'


        # check of white space
        if ($newFileName -match "\s") {
            # split by hyphen
            $splitFileName = $newFileName -split "\s"

            $newFileName = $splitFileName[0]
            $newFileName = $newFileName  + '.jpg'    
            $newFileName = $newFileName -REPLACE '.jpg.jpg', '.jpg'

            }

        write-host "current:  $fileName" 
        write-host "new: $newFileName" 
        write-host ""

        Rename-Item "$path\$fileName" "$path\$newFileName"

    }
}

