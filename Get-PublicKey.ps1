$webRequest = [Net.WebRequest]::Create("https://status.cloud.com")
try { $webRequest.GetResponse() } catch {}
$cert = $webRequest.ServicePoint.Certificate
$bytes = $cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)
set-content -value $bytes -encoding byte -path "$pwd\status.cloud.com.cer"
