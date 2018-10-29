#1: rename .jpeg to .jpg
$filePath = 'c:\temp\'

get-childitem $filePath -recurse | rename-item -newname { $_.name -replace ".jpeg",".jpg" }


$filePath = 'c:\temp\'

get-childitem $filePath -recurse | rename-item -newname { $_.name -replace "HRWL445*","HRWL445" }



