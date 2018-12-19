$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
. $currentDir\sqlcmd.ps1

$ErrorActionPreference = "Stop"

# Tail log backups captures records on the transaction log that were written since the last transaction log backup. 
# If you’re overwriting the existing database, then you won’t need a tail-log backup
function Restore-Db (
    [Parameter(mandatory=$true)][string] $dbName,
    [Parameter(mandatory=$true)][string] $dbBackupFile) {
    
    if(-Not (Test-Path $dbBackupFile)) {
        throw "Database backup file '$dbBackupFile' not found"
    }

    $restoreQuery = "USE [master]
    GO
    ALTER DATABASE [$dbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    RESTORE DATABASE [$dbName] FROM  DISK = N'$dbBackupFile' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5
    ALTER DATABASE [$dbName] SET MULTI_USER
    GO"

    Invoke-InlineSql -sqlQuery $restoreQuery
}

function Set-DbRecoveryModel (
    [Parameter(mandatory=$true)][string] $dbName,
    [ValidateSet("FULL","BULK_LOGGED","SIMPLE")] [string] $recoveryModel) {
    
    $query= "USE [master]
            GO
            ALTER DATABASE [$dbName] SET RECOVERY $recoveryModel WITH NO_WAIT
            GO"
    
    Invoke-InlineSql -sqlQuery $query    
}

function Shrink-LogFile(
    [Parameter(mandatory=$true)][string] $dbName,
    [string] $logFileName,
    [int16] $fileSize=0) {
    
    if([string]::IsNullOrEmpty($logFileName)) {
        $logFileName = $dbToRestore + "_log"
    }

    $query = "USE [$dbName]
    GO
    DBCC SHRINKFILE (N'$logFileName' , $fileSize, TRUNCATEONLY)
    GO"

    Invoke-InlineSql -sqlQuery $query
}    
