# Extracts assemblies that were "weaved" into a .net exe or .dll 
# usually the resources are named costure<original name>.compressed (at least in my sample)
# so we will attempt to extract any resource following that name pattern into same folder of the original file

$path = 'c:\test\test.exe' # filename where you want to extract from...
$destFolder = Split-Path -LiteralPath $Path
$assembly = [System.Reflection.Assembly]::LoadFrom($Path)
$resources = $assembly.GetManifestResourceNames() | where {$_.EndsWith(".compressed") -and (-not $_.Contains("costura.costura"))}
ForEach ($resource in $resources)
{
	$resourceStream = $assembly.GetManifestResourceStream($resource)
	$destFilename = $resource.Replace(".compressed", "").Replace("costura.", "")
	$destFilename = Join-Path -Path $destFolder -ChildPath $destFilename
	$destinationFileStream = [System.IO.File]::Create($destFilename)
	$decompressionStream = New-Object System.IO.Compression.DeflateStream($resourceStream, [System.IO.Compression.CompressionMode]::Decompress)
	$decompressionStream.CopyTo($destinationFileStream)
	$decompressionStream.Close()
	$destinationFileStream.Close()
	$resourceStream.Close()
}
