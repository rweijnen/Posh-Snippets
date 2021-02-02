# Posh-Snippets
PowerShell snippets

Just my collection of PowerShell snippets

Added example to call API's in Wow64ApiSet (eg to detect availability of WOW64 layer):
[bool]$MachineIsSupported = $false
$hr = [WinApi]::IsWow64GuestMachineSupported([WinApi]::IMAGE_FILE_MACHINE_I386, [ref]$MachineIsSupported)
if ($hr -eq [WinApi]::S_OK)
{
	"IsWow64GuestMachineSupported IMAGE_FILE_MACHINE_I386: $MachineIsSupported"
}

$process = [System.Diagnostics.Process]::GetCurrentProcess()

[UInt16]$processMachine = 0;
[UInt16]$nativeMachine = 0;
$bResult = [WinApi]::IsWow64Process2([WinApi]::GetCurrentProcess(), [ref]$processMachine, [ref]$nativeMachine);
if ($bResult)
{
	"ProcessMachine: $([WinApi]::MachineTypeToStr($processMachine))"
	"NativeMachine: $([WinApi]::MachineTypeToStr($nativeMachine))"
}


Added ParseWmiEvents, a small script to parse WMI queries from WMI Trace Log and measure execution time
![Alt text](https://pbs.twimg.com/media/EnlgOuDXcAMXjtK?format=jpg&name=medium "Screenshot")
