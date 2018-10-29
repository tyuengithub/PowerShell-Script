$imageFilePath = 'c:\imagefolder'

# where is the list of pubnum
$pubNumList = 'c:\temp\pubnmtest.csv'


# do not need to change if script exist in this folder
$renameScript = 'C:\Projects\Scripts\Rename_ImageFile.ps1'


# running the script to rename
& powershell -f $renameScript -pubNumFileList $pubNumList -imageFilePath $imageFilePath 

# can use this as well
# start-Process powershell -f $renameScript -pubNumFileList $pubNumList -imageFilePath $imageFilePath 

