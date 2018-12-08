function Create-DbUser (
    [Parameter(mandatory=$true)][string] $name,
    [string] $password,
    [System.Array] $serverRoles,
    [System.Array] $dbRoles) {
    
    if(!$serverRoles) {
        $defaultServerRole = "dbcreator" 
        Write-Host "No server role(s) specified, default server role '$defaultServerRole' will be used" 
        $serverRoles = @($defaultServerRole)
    }
    if(!$dbRoles) { 
        $defaultDbRole = "db_datareader" 
        Write-Host "No db role(s) specified, default db role '$defaultDbRole' will be used"
        $dbRoles = @($defaultDbRole)
    }

    $dbUser = New-Object -TypeName PSObject
    $dbUser | Add-Member -Name 'name' -MemberType Noteproperty -Value $name
    $dbUser | Add-Member -Name 'serverRoles' -MemberType Noteproperty -Value $serverRoles
    $dbUser | Add-Member -Name 'dbRoles' -MemberType Noteproperty -Value $dbRoles
    if($password) {
        $dbUser | Add-Member -Name 'password' -MemberType Noteproperty -Value $password
    }
    
    return $dbUser    
}