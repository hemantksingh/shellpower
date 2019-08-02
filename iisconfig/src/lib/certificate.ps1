
$_certificateStore = "cert:\localmachine\my"
function Add-CertificateToBinding(
    [Parameter(mandatory = $true)][string] $certificatePfxFile,
    [Parameter(mandatory = $true)][string] $certificatePassword,
    [Parameter(mandatory = $true)][system.object] $webBinding) {
        
    $certPassword = ConvertTo-SecureString -String $certificatePassword -Force -AsPlainText
    
    # Install certificate to local store, (Import-PfxCertificate is idempotent)
    $webServerCert = Import-PfxCertificate `
        -FilePath $certificatePfxFile `
        -CertStoreLocation $_certificateStore `
        -Password $certPassword

    Write-Host "Adding ssl certificate '$($webServerCert.Subject)' to web binding '$($webBinding.bindingInformation)'"
    $webBinding.AddSslCertificate($webServerCert.GetCertHashString(), "My")
}

function Add-InstalledCertificateToBinding(
    [Parameter(mandatory = $true)][string] $dnsName,
    [Parameter(mandatory = $true)][system.object] $webBinding) {
        
    # $webServerCert = Get-Item $_certificateStore\$certificateThumbprint
    $webServerCert = Get-InstalledCertificate $dnsName
    if($null -eq $webServerCert) {
        throw "No installed certificate found for dns '$dnsName'"
    }

    Write-Host "Adding ssl certificate '$($webServerCert.Subject)' to web binding '$($webBinding.bindingInformation)'"
    $webBinding.AddSslCertificate($webServerCert.GetCertHashString(), "My")
}

function Get-InstalledCertificate (
    [Parameter(mandatory = $true)][string] $dnsName) {
        
    Get-ChildItem $_certificateStore | Where-Object { $_.Subject -eq "CN=$dnsName" }
}

function Add-SelfSignedCertificate(
    [Parameter(mandatory = $true)][string] $dnsName,
    [string] $certificateFriendlyName=$dnsName) {

    $cert = Get-InstalledCertificate $dnsName
    if ($null -ne $cert) {
        Write-Warning "Certificate for '$dnsName' already exists, nothing added"
        return $cert.GetCertHashString()
    }

    Write-Host "Adding certificate with dnsname '$dnsName' and friendly name '$certificateFriendlyName'"
    $cert = New-SelfSignedCertificate `
        -certstorelocation $_certificateStore `
        -dnsname $dnsName `
        -FriendlyName $certificateFriendlyName

    Write-Host "Trusting the certificate '$dnsName'"
    $destStore = New-Object `
        -TypeName System.Security.Cryptography.X509Certificates.X509Store  `
        -ArgumentList 'root', 'LocalMachine'
    $destStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $destStore.Add($cert)
    $destStore.Close()

    return $cert.GetCertHashString()
}