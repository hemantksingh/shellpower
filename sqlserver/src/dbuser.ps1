function Create-SqlUser (
    [Parameter(mandatory=$true)][string] $name,
    [Parameter(mandatory=$true)][string] $password,
    [System.Array] $serverRoles,
    [System.Array] $dbRoles) {
    
    if(!$serverRoles) { 
        Write-Host "No server role(s) specified" 
        $serverRoles = @("dbcreator")
    }
    if(!$dbRoles) { 
        Write-Host "No db role(s) specified" 
        $dbRoles = @("db_datareader")
    }

    $sqlUser = New-Object -TypeName PSObject
    $sqlUser | Add-Member -Name 'name' -MemberType Noteproperty -Value $name
    $sqlUser | Add-Member -Name 'password' -MemberType Noteproperty -Value $password
    $sqlUser | Add-Member -Name 'serverRoles' -MemberType Noteproperty -Value $serverRoles
    $sqlUser | Add-Member -Name 'dbRoles' -MemberType Noteproperty -Value $dbRoles
    
    return $sqlUser
}