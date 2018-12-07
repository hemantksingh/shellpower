function Create-SqlUser (
    [Parameter(mandatory=$true)][string] $name,
    [Parameter(mandatory=$true)][string] $password,
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

    $sqlUser = New-Object -TypeName PSObject
    $sqlUser | Add-Member -Name 'name' -MemberType Noteproperty -Value $name
    $sqlUser | Add-Member -Name 'password' -MemberType Noteproperty -Value $password
    $sqlUser | Add-Member -Name 'serverRoles' -MemberType Noteproperty -Value $serverRoles
    $sqlUser | Add-Member -Name 'dbRoles' -MemberType Noteproperty -Value $dbRoles
    
    return $sqlUser
}