# shellpower.sqlserver

Provides powershell cmdlets for managing and configuring sql server in a repeatable manner, ideal for continuous integration/deployment scenarios.

## Usage

* Install nuget package

    ```sh
    nuget install shellpower.sqlserver -outputdirectory packages
    ```

* Create new file `getting-started.ps1` with the following content

    ```powershell

    # dot source the script
    . packages\bin\sqlserver.ps1

    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    $server = new-object Microsoft.SqlServer.Management.Smo.Server("localhost")

    # Create sql login
    Create-Login $server "test-user" "testpassw0rd!"

    # Create windows login
    Create-Login $server "testdomain\testuser"
    ```

* Run `.\getting-started.ps1`

Refer to the [tests](./tests) in the source code for more examples.