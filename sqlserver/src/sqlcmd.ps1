param (
  [Parameter(Mandatory = $true)][string] $dbServer,
  [string] $dbName
)

function Handle-Result(
    [Parameter(mandatory=$true)][string] $sqlQuery,
    [Parameter(mandatory=$true)][System.Object] $out) {
    $nl = [Environment]::NewLine    
    if ($LASTEXITCODE -ne 0) {
        throw "An error occurred while running sql $nl'$sqlQuery'$nl" + "ERROR: $out"
    } else {
        Write-Host $out
    }
}
function Invoke-InlineSql(
    [Parameter(mandatory=$true)][string] $sqlQuery,
    [string] $trustedConnection=$true,
    [string] $dbUser,
    [string] $dbPassword) {
        
    if($dbName) {
        Write-Host "Using database '$dbName'"
        $sqlQuery = "USE $dbName " + $sqlQuery
    }

    if($trustedConnection) {
        Write-Host "Using trusted connection to connect to '$dbServer'"
        $out = sqlcmd -S $dbServer -E -Q $sqlQuery -b
    } else  {
        Write-Host "Using db credentials to connect to '$dbServer'"
        $out = sqlcmd -S $dbServer -U $dbUser -P $dbPassword -Q $sqlQuery -b
    }

    Handle-Result $sqlQuery $out
}

