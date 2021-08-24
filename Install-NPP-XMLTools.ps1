# downloads the latest version of XML tools and adds it to Notepad++ (if no previous version was installed)
$temp = 'C:\Temp'

$pluginPath = 'c:\Program Files (x86)\Notepad++\plugins\XMLTools\XMLTools.dll'
if (-not (Test-Path $pluginPath))
{
	$uri = 'https://raw.githubusercontent.com/notepad-plus-plus/nppPluginList/master/src/pl.x86.json'
	$json = Invoke-RestMethod -Uri $uri
	$xmlTools = $json.'npp-plugins' | where {$_.'display-name' -eq 'XML Tools'}
	$filename = Split-Path $xmlTools.repository -Leaf
	$path = Join-Path -Path $temp -ChildPath $filename
	Invoke-WebRequest -Uri $xmlTools.repository -OutFile $path
	Expand-Archive $path (Split-Path $pluginPath) -Force
	Remove-Item $path
}

