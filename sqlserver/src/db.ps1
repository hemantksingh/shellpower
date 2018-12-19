function Get-RestoreSql(
    [Parameter(mandatory=$true)][string] $dbToRestore,
    [Parameter(mandatory=$true)][string] $backupFile
) {
    if(-Not (Test-Path $backupFile)) {
        throw "Unable to find file '$backupFile'"
    }

    return "ALTER DATABASE [$dbToRestore] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    RESTORE DATABASE [$dbToRestore] FROM  DISK = N'$backupFile' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5
    ALTER DATABASE [$dbToRestore] SET MULTI_USER
    
    GO"
}

function Get-RecoveryModelSql(
    [Parameter(mandatory=$true)][string] $dbName,
    [ValidateSet("FULL","BULK_LOGGED","SIMPLE")] [string] $recoveryModel) {
        return "USE [master]
        GO
        ALTER DATABASE [$dbName] SET RECOVERY $recoveryModel WITH NO_WAIT
        GO"
}

function Get-ShrinkFileSql(
    [Parameter(mandatory=$true)][string] $dbName,
    [string] $logFileName,
    [int16] $fileSize=0) {

        if([string]::IsNullOrEmpty($logFileName)) {
            $logFileName = $dbToRestore + "_log"
        }
        return "USE [$dbName]
        GO
        DBCC SHRINKFILE (N'$logFileName' , $fileSize, TRUNCATEONLY)
        GO"
}

# Tail log backups captures records on the transaction log that were written since the last transaction log backup. 
# If you’re overwriting the existing database, then you won’t need a tail-log backup
    
