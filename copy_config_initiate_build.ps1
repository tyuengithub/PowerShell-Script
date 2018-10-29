<#
    Purpose: the script will copy the config file from PROD that is 24 hrs old and initiate the Endeca Linux build
    Create Date: 8/11/2016
    Created By: Tommy Yuen

#>



#region declaration

# this command to stop the output wrap around
$host.UI.RawUI.BufferSize = new-object System.Management.Automation.Host.Size(3000,50)


$sourceEnv = 'PROD'
$targetEnv = 'REL'

$indexList = @("WebZ1L1", "WebZ2L1", "WebZ2L2", "WebZ2L3", "WebZ2L4", "WebZ2L5"
    , "WebZ2L7", "WebZ2L8", "WebZ2L10", "WebZ2L11", "WebZ3L1", "WebZ4L1", "WebZ5L6"
    , "WebZ9L1", "WebZ10L1", "WebZ12L2", "WebZ13L3", "WebZ20L12", "WebZ25L2", "WebZ100L1"
    )


$logFileName = 'EndecaFullBuild_' + (Get-Date -Format yyyMMdd) + '.log'
$logfile = "D:\Logs\EndecaFullBuild\$logFileName"
#endregion declaration



#region generating script information
try {

# to redirect output message to a log file, there is a "stop-transacript" at the bottom of the file
START-TRANSCRIPT -append -path $logfile

}
catch {

# file is locked, closing this file
STOP-TRANSCRIPT 

START-TRANSCRIPT -append -path $logfile
}
#endregion


# copy production dimension files generate from yesterday to the environment
FOREACH ($index in $indexList) {
    GET-CHILDITEM -Path "\\network_folder\endeca\$sourceEnv\$index\config\pipeline" | `
    FOREACH {

        # check for files that are 24 hrs old and copy the files from PROD to target environment
        if ($_.LastWriteTime -GT (GET-DATE).AddDays(-1)) {
            WRITE-OUTPUT ((GET-DATE -format('MM/dd/yyyy hh:mm:ss ')) + "copying file from: " + $_.FullName  + " to  \\network_folder\endeca\$targetEnv\$index\config\pipeline\ `r")
            COPY-ITEM $_.FullName "\\network_folder\endeca\$targetEnv\$index\config\pipeline\" -Force
        }

    }

}

WRITE-OUTPUT ((GET-DATE -format('MM/dd/yyyy hh:mm:ss ')) + "Complete copying dimension files for Endeca Build from $sourceEnv to $targetEnv")



# start Endeca Linux Build
FOREACH ($index in $indexList) {
    WRITE-OUTPUT ((GET-DATE -format('MM/dd/yyyy hh:mm:ss ')) + "Start Endeca Linux Build $index `r")

    # start each build in the list
    START-PROCESS -FilePath "D:\Applications\EndecaFileGeneration\$index\StartEndecaBuild.bat"
}

WRITE-OUTPUT ((GET-DATE -format('MM/dd/yyyy hh:mm:ss ')) + "Complete initiated Endeca Linux Build for $targetEnv")


# stop output to file 
STOP-TRANSCRIPT 
