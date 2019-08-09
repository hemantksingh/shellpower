
$_certificateStore = "cert:\localmachine\my"
function Add-CertificateToBinding(
    [Parameter(mandatory = $true)][string] $certificatePfxFile,
    [Parameter(mandatory = $true)][string] $certificatePassword,
    [Parameter(mandatory = $true)][system.object] $webBinding) {
        
    $certPassword = ConvertTo-SecureString -String $certificatePassword -Force -AsPlainText
    
    # Install certificate to local store, (Import-PfxCertificate is idempotent)
    $cert = Import-PfxCertificate `
        -FilePath $certificatePfxFile `
        -CertStoreLocation $_certificateStore `
        -Password $certPassword

    Write-Host "Adding ssl certificate '$($cert.Subject)' to web binding '$($webBinding.bindingInformation)'"
    $webBinding.AddSslCertificate($cert.GetCertHashString(), "My")
}

function Add-InstalledCertificateToBinding(
    [Parameter(mandatory = $true)][string] $dnsName,
    [Parameter(mandatory = $true)][system.object] $webBinding) {
        
    $cert = Get-InstalledCertificateByDns $dnsName
    if($null -eq $cert) {
        throw "No installed certificate found for dns '$dnsName'"
    }

    Write-Host "Adding ssl certificate with subject '$($cert.Subject)' to web binding '$($webBinding.bindingInformation)'"
    $webBinding.AddSslCertificate($cert.GetCertHashString(), "My")
}

function Get-InstalledCertificateByDns (
    [Parameter(mandatory = $true)][string] $dnsName) {
        
    $certs = Get-ChildItem $_certificateStore | Where-Object { $_.Subject -match $dnsName }
    if($certs.length -gt 1) {
        Handle-MultipleMatches $certs $dnsName
        Write-Host "Looking for an exact match for 'CN=$dnsName'"
        $exactCerts = $certs | Where-Object { $_.Subject -eq "CN=$dnsName"}
        Handle-MultipleMatches $exactCerts "CN=$dnsName"

        if($exactCerts.length -eq 1 -or $exactCerts.length -gt 1) {
            $certs = $exactCerts
        }
    }
    return $certs | Select-Object -First 1
}


function Handle-MultipleMatches($certificates, $dnsName) {
    if($certificates.length -eq 1) {
        Write-Host "Exact certificate match found for '$dnsName'"
    } 
    elseif ($certificates.length -gt 1) {
        Write-Warning "Multiple certificates installed matching '$dnsName'"
        $certificates | foreach-object {
            Write-Host "$($_.Subject) $($_.Thumbprint)"
        }
    } 
    else {
        Write-Host "No certificate installed matching '$dnsName'"
    }
}

function Get-InstalledCertificateByThumbprint (
    [Parameter(mandatory = $true)][string] $certificateThumbprint) {
        
    Get-Item $_certificateStore\$certificateThumbprint
}

function Add-SelfSignedCertificate(
    [Parameter(mandatory = $true)][string] $dnsName,
    [string] $certificateFriendlyName=$dnsName) {

    $cert = Get-InstalledCertificateByDns $dnsName
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