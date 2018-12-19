param (
  [Parameter(Mandatory = $true)][string] $dbServer
)

$ErrorActionPreference = "Stop"
$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
. $currentDir\sqlcmd.ps1 -dbServer $dbServer

function Backup-Db(
    [Parameter(mandatory=$true)][string] $dbName,
    [Parameter(mandatory=$true)][string] $dbBackupFile) {
    
    $backupName = "{0}-Full Database Backup" -f $dbName
    $query = "BACKUP DATABASE [$dbName] TO  DISK = N'$dbBackupFile' WITH NOFORMAT, INIT,  NAME = N'$backupName', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
    GO"
    Write-Host "Backing up database '$dbName' to file '$dbBackupFile'"
    Invoke-InlineSql -sqlQuery $restoreQuery
}

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

    Write-Host "Restoring database '$dbName' with backup file '$dbBackupFile'"
    Invoke-InlineSql -sqlQuery $restoreQuery
}

function Set-DbRecoveryModel (
    [Parameter(mandatory=$true)][string] $dbName,
    [ValidateSet("FULL","BULK_LOGGED","SIMPLE")] [string] $recoveryModel) {
    
    $query= "USE [master]
            GO
            ALTER DATABASE [$dbName] SET RECOVERY $recoveryModel WITH NO_WAIT
            GO"
    Write-Host "Setting '$dbName' recovery model to '$recoveryModel'"
    Invoke-InlineSql -sqlQuery $query    
}

function Shrink-LogFile(
    [Parameter(mandatory=$true)][string] $dbName,
    [string] $logFileName,
    [int16] $fileSize=0) {
    
    if([string]::IsNullOrEmpty($logFileName)) {
        $logFileName = $dbName + "_log"
    }

    Write-Host "Shrinking logfile '$logFileName' to '$fileSize' Mb"

    $query = "USE [$dbName]
    GO
    DBCC SHRINKFILE (N'$logFileName' , $fileSize, TRUNCATEONLY)
    GO"

    Invoke-InlineSql -sqlQuery $query
}    
