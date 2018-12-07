# Fails with "FailedOperationException" if the password does not meet
# sql server complexity requirements
$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
. $currentDir\dbuser.ps1
function Create-Login(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Server] $server,
    [Parameter(mandatory = $true)][string] $loginName,
    [string] $password) {
    
    Write-Host "Creating login '$loginName' on server '$server'"
    if ($server.Logins.Contains($loginName)) {
        Write-Host "Login '$loginName' already exists, nothing created"
        return $server.Logins[$loginName]
    }

    $login = New-Object `
        -TypeName Microsoft.SqlServer.Management.Smo.Login `
        -ArgumentList $server, $loginName

    if ($password) {
        Write-Host "Creating SqlLogin '$loginName' on server '$server'"
        $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
        $login.PasswordExpirationEnabled = $false
        $login.Create($password)
    }
    else {
        Write-Host "Creating WindowsUser '$loginName' on server '$server'"
        $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::WindowsUser
        $login.Create()
    }
    return $login
}

function Add-SqlUser (
    [Parameter(mandatory=$true)][string] $dbServer,
    [Parameter(mandatory=$true)][string] $dbName,
    [Parameter(mandatory=$true)][PSObject]$sqlUser) {
    
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    $server = new-object Microsoft.SqlServer.Management.Smo.Server($dbServer)
    
    $userLogin = Create-Login $server $sqlUser.name $sqlUser.password
    Add-LoginToServerRoles $server $userLogin.Name $sqlUser.serverRoles

    $db = Create-Db $server $dbName
    Add-UserToDb $db $sqlUser.name
    Add-UserToDbRoles $db $sqlUser.name $sqlUser.dbRoles
}

function Remove-SqlUser(
    [Parameter(mandatory=$true)][string] $dbServer,
    [Parameter(mandatory=$true)][string] $dbName,
    [Parameter(mandatory=$true)][string] $sqlUser) {

    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    $server = new-object Microsoft.SqlServer.Management.Smo.Server($dbServer)
    $db = Get-Db $server $dbName

    Remove-UserFromDb $db $sqlUser
    Remove-LoginFromServer $server $sqlUser
}

function Remove-LoginFromServer(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Server] $server,
    [Parameter(mandatory = $true)][string] $loginName) {
    $login = $server.Logins[$loginName]
    if ($login) {
        Write-Host "Removing '$loginName' of type "$login.LoginType" on '$server'"
        $login.Drop()
    }
    else {
        Write-Host "'$loginName' not found on '$server', nothing removed"
    }
}
function Add-LoginToServerRole(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Server] $server,
    [Parameter(mandatory = $true)][string] $loginName,
    [Parameter(mandatory = $true)][string] $roleName) {

    Write-Host "Adding login '$loginName' to server role '$roleName'"
    $role = $server.Roles[$roleName]
    $role.AddMember($loginName)
    $role.Alter()
}

function Add-LoginToServerRoles(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Server] $server,
    [Parameter(mandatory = $true)][string] $loginName,
    [Parameter(mandatory = $true)][System.Array] $roleNames) {
        $roleNames | foreach-object  {
            Add-LoginToServerRole $server $loginName $_
        }
}
function Create-Db(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Server] $server,
    [Parameter(mandatory = $true)][string] $name) {
    $database = Get-Db $server $name
    if ($database) {
        return $database
    }
    Write-Host "Creating database '$name'"
    $database = New-Object `
        -TypeName Microsoft.SqlServer.Management.Smo.Database `
        -argumentlist $server, $name
    $database.Create()

    return $database
}

function Get-Db(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Server] $server,
    [Parameter(mandatory = $true)][string] $name) {
    if ($server.Databases.Contains($name)) {
        return $server.Databases.Item($name)
    }
    else {
        Write-Host "No database '$name' found on server '$server'"
        return
    }
}
function Add-UserToDb(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Database]$database,
    [Parameter(mandatory = $true)][string] $user) {
    
    Write-Host "Adding user '$user' to database '$database'"
    if ($database.Users.Contains($user)) {
        Write-Host "User '$user' already exists, nothing added"
        return
    }
    
    $usr = New-Object `
        -TypeName Microsoft.SqlServer.Management.Smo.User `
        -argumentlist $database, $user
    $usr.Login = $user
    $usr.Create()
}

function Add-UserToDbRole(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Database]$database,
    [Parameter(mandatory = $true)][string] $user,
    [Parameter(mandatory = $true)][string] $roleName) {
    Write-Host "Adding user '$user' to role '$roleName' on database '$database'"
    $role = $database.Roles[$roleName]
    $role.AddMember($user)
    $role.Alter()
}

function Add-UserToDbRoles(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Database]$database,
    [Parameter(mandatory = $true)][string] $user,
    [Parameter(mandatory = $true)][System.Array] $roleNames) {
        $roleNames | foreach-object  {
            Add-UserToDbRole $database $user $_
        }
}

function Remove-UserFromDb(
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Database]$database,
    [Parameter(mandatory = $true)][string] $user) {
    if ($database.Users.Contains($user)) {
        Write-Host "Removing '$user' from database '$database'"
        $database.Users[$user].Drop()
    }
    else {
        Write-Host "'$user' not found in '$database', nothing removed"
    }
}