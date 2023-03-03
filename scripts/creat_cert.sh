New-SelfSignedCertificate -Type Custom -Subject "CN=FPE, O=FPE, C=DE" -KeyUsage DigitalSignature -FriendlyName "FPE" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")

Set-Location Cert:\CurrentUser\My
Get-ChildItem | Format-Table Subject, FriendlyName, Thumbprint

$password = ConvertTo-SecureString -String 123456 -Force -AsPlainText
Export-PfxCertificate -cert "Cert:\CurrentUser\My\69DE411C79E8C3D72F74FDE3B5152B6896C6BC24" -FilePath brick-converter.pfx -Password $password
