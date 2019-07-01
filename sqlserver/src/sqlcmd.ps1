param (
  [Parameter(Mandatory = $true)][string] $dbServer
)

function Handle-Result(
    [Parameter(mandatory=$true)][string] $sqlQuery,
    [Parameter(mandatory=$false)][System.Object] $out) {
    $nl = [Environment]::NewLine    
        
    if ($LASTEXITCODE -ne 0) {
        Write-Host "LASTEXITCODE: $LASTEXITCODE"
        throw "An error occurred while running sql $nl'$sqlQuery'$nl" + "ERROR: $out"
    } elseif ( $null -eq $out ) {
        Write-Host "SQL command executed successfully!!!"
    }
    else {
        Write-Host $out
    }
}
function Invoke-InlineSql(
    [Parameter(mandatory=$true)][string] $sqlQuery,
    [bool] $trustedConnection=$true,
    [string] $dbUser,
    [string] $dbPassword) {
        
    if($dbUser -and $dbPassword) {
        Write-Debug "Disabling trusted connection"
        $trustedConnection=$false
    }

    if($trustedConnection) {
        Write-Host "Running query using trusted connection on '$dbServer'"
        $out = sqlcmd -S $dbServer -E -Q $sqlQuery -b
    } else  {
        Write-Host "Running query using db credentials on '$dbServer'"
        $out = sqlcmd -S $dbServer -U $dbUser -P $dbPassword -Q $sqlQuery -b
    }

    Handle-Result $sqlQuery $out
}

function Invoke-SqlFile(
    [Parameter(mandatory=$true)][string] $sqlFile,
    [bool] $trustedConnection=$true,
    [string] $dbUser,
    [string] $dbPassword) {
    
    if($dbUser -and $dbPassword) {
        Write-Debug "Disabling trusted connection"
        $trustedConnection=$false
    }

    if($trustedConnection) {
        Write-Host "Using trusted connection to connect to '$dbServer'"
        $out = sqlcmd -S $dbServer -E -i $sqlFile -b
    } else  {
        Write-Host "Using db credentials to connect to '$dbServer'"
        $out = sqlcmd -S $dbServer -U $dbUser -P $dbPassword -i $sqlFile -b
    }

    Handle-Result $sqlFile $out
}

function Run-SqlCommand([Parameter(mandatory=$true)][string] $sql,
    [bool] $trustedConnection=$true,
    [bool] $isFile=$false,
    [string] $dbUser,
    [string] $dbPassword) {
    
    if($dbUser -and $dbPassword) {
        Write-Debug "Disabling trusted connection"
        $trustedConnection=$false
    }

    if($isFile) {$params = "-i $sql -b"} else {$params = "-Q $sql -b"}
    if($trustedConnection -eq $true) {
        Write-Host "Using trusted connection to connect to '$dbServer'"
        $out = sqlcmd -S $dbServer -E $params
    } else  {
        Write-Host "Using db credentials to connect to '$dbServer'"
        $out = sqlcmd -S $dbServer -U $dbUser -P $dbPassword $params
    }
    
    Handle-Result $sqlQuery $out
}