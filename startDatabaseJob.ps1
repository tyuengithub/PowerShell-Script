<#
    Purpose: To Start SQL Server Job with intergrated security
    Date: 3/1/2016
    Note: 
        - The client will pass the server name and the database job name
        - the initiator of the call to connect to the database must have access to the database
#>


$sqlConn = New-Object System.Data.SqlClient.SqlConnection "server=$server;database=$database;Integrated Security=sspi;Application Name=Powershell Script"

# Open Database Connection
function DatabaseConnection {

    #Vars for Server and JobName
    param([string]$server, [string]$action, [string]$database)

    # create new database object
    $sqlConn = New-Object System.Data.SqlClient.SqlConnection "server=$server;database=$database;Integrated Security=sspi;Application Name=Powershell Script"

    if ($action -eq "open") {
        $sqlConn.Open()
    }
    else {
        $sqlConn.Close()
    }

  return
}



function startDatabaseJob {

    #Vars for Server and JobName
    param([string]$Server, [string]$JobName)


    #Create/Open Connection
    DatabaseConnection -Action "open" -Server $Server -database "msdb"

    #Create Command Obj
    $sqlCommand = $sqlConn.CreateCommand()
    $sqlCommand.CommandText = "EXEC dbo.sp_start_job N'$JobName'"

    #Exec Command
    $sqlCommand.ExecuteReader()

    #Close Conneection
    DatabaseConnection -Action "close" -Server $Server
}




<# function to update item with image information #>
function runTSQLScript ([string]$server, [string]$database, [string]$tsqlScript)
{
# open database connection
    $connection = New-Object System.Data.SqlClient.SqlConnection "server=$server;database=$database;Integrated Security=sspi;Application Name=Powershell Script"

    write-host (get-date -format('MM/dd/yyyy hh:mm:ss')) "Connecting to database $database"

    $connection.Open()

    # create database command object
    $command = $connection.CreateCommand()


    $query = $tsqlScript

    # assign query string for execution
    $command.CommandText = $query 

    write-host (get-date -format('MM/dd/yyyy hh:mm:ss')) "Running: $query "

    # database call
    $result = $command.ExecuteNonQuery()

    # open database connection
    $connection.Close()

    write-host (get-date -format('MM/dd/yyyy hh:mm:ss')) "Closing connection to database $database"

    return

}




