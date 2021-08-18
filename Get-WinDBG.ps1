cls
$IsElevated = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'
if (-not ($IsElevated))
{
    Write-Warning "script is not running elevated, attempting to launch with elevated powershell..."
    Start-Process "powershell.exe" -ArgumentList $MyInvocation.MyCommand.Path -Wait -Verb RunAs
}
else
{
    Write-Host "We are elevated..."

    $symbolFolder = 'C:\Symbols'

    Write-Host "Downloading SDK Installer"

    # Download Installer
    $url = "https://go.microsoft.com/fwlink/p/?linkid=2083338&clcid=0x409"
    $wc = New-Object System.Net.WebClient
    $request = [System.Net.WebRequest]::Create($url)
    $response = $request.GetResponse()
    $outputFile = [System.IO.Path]::GetFileName($response.ResponseUri)
    $response.Close()
    $filePath = "C:\ProgramData\$outputFile"
    $wc.DownloadFile($url, $filePath)
    if (!(Test-Path $filePath)) { Write-Error "Welp!" }

    # Install Windows Debuggers - Silently
    Write-Host "Installing Windows Debuggers..." 

    Start-Process $filePath -Wait -ArgumentList '/features OptionId.WindowsDesktopDebuggers /ceip off /q'
    if (-not (Test-Path $symbolFolder))
    {
        New-Item -ItemType Directory -Path $symbolFolder
    }

    Write-Host "Setting _NT_SYMBOL_PATH..." 
    [System.Environment]::SetEnvironmentVariable("_NT_SYMBOL_PATH", "srv*$symbolFolder*http://msdl.microsoft.com/download/symbols", "Machine")
    Remove-Item $FilePath
}

Write-Host "Finished, press Enter to continue"
[Console]::ReadKey() | Out-Null -ErrorAction:SilentlyContinue
