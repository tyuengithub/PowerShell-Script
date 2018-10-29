<#
    Purpose: the script will check to see if Endeca Full Build is running.  If not running, then trigger price migration
    Create Date: 5/23/2016
    Created By: Tommy Yuen

#>

#region include other powershell script
# to include the powershell script to connect to database, the period infront is to indicate "include"

IMPORT-MODULE "C:\Projects\PriceMigrationDelay\generalFunction.ps1"
IMPORT-MODULE "C:\Projects\PriceMigrationDelay\databaseFunction.ps1"

#endregion

#region variable declaration
$environment = 'dev'
$endecaNetworkBasePath = 'network_folder'
$logFileName = 'PriceMigrationJob_' + (Get-Date -Format yyyMMdd) + '.log'
$logfile = "C:\Logs\PriceListMigration\$logFileName"
$server = 'database_server'
$database = 'database'

#endregion


#region generating script information
try {

# to redirect output message to a log file, there is a "stop-transacript" at the bottom of the file
start-transcript -append -path $logfile

}
catch {

# file is locked, closing this file
stop-transcript 

}
#endregion


#region processFullBuildSignalFile
function processFullBuildSignalFile {

    #Vars for Server and JobName
    param([string]$endecaIndex, [string]$signalFile, [string]$fullBuildTime, [string]$server, [string]$jobName)


    write-host (get-date -format('MM/dd/yyyy hh:mm:ss ')) "Checking for $endecaIndex"


    # check if the full build signal file exit
    IF (!(Test-Path $signalFile))
    {

        # if signal not found, will run price migration job
        write-host (get-date -format('MM/dd/yyyy hh:mm:ss')) (Split-Path -Leaf $signalFile) " not found.  Starting Price Migration job for $endecaIndex"

        # runTSQLScript -server $server -database $database -tsqlScript $sqlScript
        startDatabaseJob -Server $server -JobName $jobName

    }
    ELSE
    {

        # if signal file found, will not run price migration job
        write-host (get-date -format('MM/dd/yyyy hh:mm:ss'))  (Split-Path -Leaf $signalFile) " found.  Price Migration job will not started for $endecaIndex"


        # check to see if build is running too long.  if yes, will send email to team
        checkSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime

    }

}
#endregion


#region WebZ1L1 (apc.com)
$endecaIndex = 'WebZ1L1'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 1"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion



#region WebZ3L1 (art.com)
$endecaIndex = 'WebZ3L1'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 3"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion



#region WebZ4L1 (art.co.uk)
$endecaIndex = 'WebZ4L1'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 4"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion



#region WebZ5L6 (apc.co.jp)
$endecaIndex = 'WebZ5L6'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 5"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion



#region WebZ12L2 (apc.fr)
$endecaIndex = 'WebZ12L2'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 5"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion



#region Web13L3 (apc.de)
$endecaIndex = 'WebZ13L3'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 13"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion



#region Web20L12 (apc.com.br)
$endecaIndex = 'WebZ20L12'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 20"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion




#region Web25L2 (art.fr)
$endecaIndex = 'WebZ25L2'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 25"
$fullBuildTime = 360

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion




#region WebZ100L1 (Conde Nast)
$endecaIndex = 'WebZ100L1'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"


# Database info
$jobName = "Price List Migration – Zone 1"
$fullBuildTime = 240

# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Oaky')"


processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion



#region WebZ2L1 (apc.co.uk)
$endecaIndex = 'WebZ2L1'
$signalFile = "$endecaNetworkBasePath\$environment\$endecaIndex\$endecaIndex.endecaFullBuildRunning.txt"

# Database info
# $sqlScript = "INSERT INTO tommyTest (Status) VALUES ('Okay')"
$jobName = "Price List Migration – Zone 2"
$fullBuildTime = 300

processFullBuildSignalFile -endecaIndex $endecaIndex -signalFile $signalFile -fullBuildTime $fullBuildTime -server $server -jobName $jobName

#endregion





# stop logging output
stop-transcript 
