<#
Powershell script to rename folder
#>


# Original Folder
$folderName = "c:\tempList"

# New Folder
$newFolderName = $folderName + '_' + (Get-Date -Format "yyyMMddHHmmss")


# Rename Folder
RENAME-ITEM $folderName $newFolderName


# create new folder
NEW-ITEM -TYPE directory -path $folderName
