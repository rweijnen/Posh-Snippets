#unfinished as it was time to board, leaving it here as someone might find it useful

$key = @"
[
{
    "domain": "portal.live.virginwifi.com",
    "expirationDate": 1706633213.135671,
    "hostOnly": true,
    "httpOnly": true,
    "name": "argo_session",
    "path": "/",
    "sameSite": "no_restriction",
    "secure": false,
    "session": false,
    "storeId": "0",
    "value": "eyJpdiI6IjBSeTBPZWI5WFwvcGVXZmJjV2JDaHN3PT0iLCJ2YWx1ZSI6IlNmM0I3OFwvdlg4blNSZmN0d2JQUzVjOExtV0pId2N2bDd6TUlra2d3WjNOMHk2OFJzdDBUU1wvMUZtVEJpSXM0WUtHb0xZbHFaajVPUnFEYnkrRXJjVWc9PSIsIm1hYyI6IjNmMmIwZGQxNzY2YjAxNGYwY2M3MDI3OTUxZTJkZmEyMmYyYzhiNTY0MjAwN2UxZTNjZDg5YWZhNzI0OTcwNjAifQ%3D%3D",
    "id": 1
}
]
"@

function Create-AesManagedObject($key, $IV) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

function Create-AesKey() {
    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

function Encrypt-String($key, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}
function BinToHex {
	param(
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true)
	]
	[Byte[]]$Bin)
	# assume pipeline input if we don't have an array (surely there must be a better way)
	if ($bin.Length -eq 1) {$bin = @($input)}
	$return = -join ($Bin |  foreach { "{0:X2}" -f $_ })
	Write-Output $return
}
 
function HexToBin {
	param(
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true)
	]	
	[string]$s)
	$return = @()
	
	for ($i = 0; $i -lt $s.Length ; $i += 2)
	{
		$return += [Byte]::Parse($s.Substring($i, 2), [System.Globalization.NumberStyles]::HexNumber)
	}
	
	Write-Output $return
}

$data = ConvertFrom-Json $key
$base64Value = $data[0].value -replace '%3D', '='
$val = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Value))
#$value = [System.Convert]::FromBase64String($base64Value)
$moreData = ConvertFrom-Json $val
$iv = [System.Convert]::FromBase64String($moreData.iv)
$value = [System.Convert]::FromBase64String($moreData.value)

$mac = [System.Convert]::FromBase64String($moreData.mac)
$mac2 =  HexToBin $moreData.mac
$mac3 = $enc.GetString($mac2)
#$hmacsha = New-Object System.Security.Cryptography.HMACSHA256(

$aesManaged = New-Object "System.Security.Cryptography.AesManaged"
$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
$aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
$aesManaged.BlockSize = 128
$aesManaged.KeySize = 128
$aesManaged.IV = $iv
$enc = [system.Text.Encoding]::UTF8

# just a guess, would they be using the supplied e-mail address as the key??
$aesManaged.Key =  $mac2 #$enc.GetBytes('<EMAIL ADDRESS>')
$decryptor = $aesManaged.CreateDecryptor()
#$unencryptedData = $decryptor.TransformFinalBlock($mac, 16, $mac.Length - 16);
$aesManaged.Dispose()
[System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)


#$decodedValue = 
