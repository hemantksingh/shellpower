$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\iisconfig\src\" -Verbose).FullName
$tests =  (Get-Item -Path ".\iisconfig\tests\" -Verbose).FullName

Write-Host "Importing from source $source"
. $source\iisconfig.ps1
. $tests\testutil.ps1

$_root = "$env:TEMP\shellpower" # This is ususally 'C:\inetpub'

function Test-WebApplicationCanBeCreatedForValidWebSite {
    $siteName = "shellpower1"
    $webapp ="api"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath

    Add-WebApplicationToWebSite -siteName $siteName `
        -sitePath $sitePath `
        -webappName $webapp `
        -webappPath $webappPath

    $actual = (Get-WebApplication -Name $webapp -Site $siteName) | 
        Select-Object @{Name='Name'; Expression={$_.Path.trim('/')}}

    $actual1 = (Get-WebApplication -Name $webapp -Site $siteName) | 
        Select-Object @{Name='AppPool'; Expression={$_.applicationPool}}

    $expected =  "{0}_{1}" -f $siteName, $webapp
    Assert-Equal $webapp $actual.Name
    Assert-Equal $expected $actual1.AppPool
}

function Test-WebApplicationWithIdentityCanBeCreatedForValidWebSite {
    $siteName = "shellpower1"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath

    Add-WebApplicationToWebSite -siteName $siteName `
        -sitePath $sitePath `
        -webappName "api" `
        -webappPath $webappPath `
        -webappUsername "sample-user" `
        -webappPassword "apassword"

    Assert-Equal $siteName (Get-Website -Name $siteName).Name
}

function Test-WebApplicationCannotBeCreatedForInvalidWebSiteIfCreateWebsiteOptionsIsNotSpecified  {

    $siteName = "invalidsite"
    $webappName = "api"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath
    try {
        Add-WebApplicationToWebSite -siteName $siteName `
            -webappName $webappName `
            -webappPath $webappPath
    } catch {
        Assert-Equal "Failed to create web application '$webappName', website '$siteName' was not found" `
            $_.Exception.Message
    }
}

function Test-WebApplicationCanBeCreatedForValidVirDir {
    
    $siteName = "shellpower2"
    $virDirName = "vir"
    $webappName = "api"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $virDirPath = "$_root\$siteName\$virDirName"; Ensure-PathExists $virDirPath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath

    Add-WebApplicationToVirtualDirectory -siteName $siteName `
        -sitePath $sitePath `
        -virDirName $virDirName `
        -virDirPath $virDirPath `
        -webappName $webappName `
        -webappPath $webappPath `
        -webappUsername "sample-user" `
        -webappPassword "apassword"
    
    # Web application is recreated for an existing website and vir dir

    Add-WebApplicationToVirtualDirectory -siteName $siteName `
        -virDirName $virDirName `
        -webappName $webappName `
        -webappPath $webappPath `
        -webappUsername "sample-user1" `
        -webappPassword "apassword"
}

function Test-WebApplicationCannotBeCreatedForInValidVirDirIfCreateVirDirOptionIsNotSpecified {
    
    $siteName = "shellpower2"
    $virDirName = "invalidvir"
    $webappName = "api"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath

    Add-WebApplicationToVirtualDirectory -siteName $siteName `
        -sitePath $sitePath `
        -virDirName $virDirName `
        -webappName $webappName `
        -webappPath $webappPath
}

function Test-CreateWebsiteWithCertificate {
    
    $certificateThumbprint = Add-SelfSignedCertificate -dnsName 'localhost'
    $siteName = "shellpower3"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath

    Create-Website $siteName -port 443 `
        -appPool $siteName `
        -physicalPath $sitePath `
        -protocol 'https' `
        -certificateThumbprint $certificateThumbprint
}

function Remove-Setup {
    Remove-Website -Name "shellpower1"; Remove-WebAppPool -Name "shellpower1"; 
    Remove-WebAppPool -Name "shellpower1_api"
    Remove-Website -Name "shellpower2"; Remove-WebAppPool -Name "shellpower2";
    Remove-WebAppPool -Name "shellpower2_vir_api"
    Remove-Item -Path $_root -Recurse -Force
}

# Remove-Setup
Test-WebApplicationCanBeCreatedForValidWebSite
Test-WebApplicationCannotBeCreatedForInvalidWebSiteIfCreateWebsiteOptionsIsNotSpecified
Test-WebApplicationCanBeCreatedForValidVirDir
Test-CreateWebsiteWithCertificate
# Test-WebApplicationCannotBeCreatedForInValidVirDirIfCreateVirDirOptionIsNotSpecified