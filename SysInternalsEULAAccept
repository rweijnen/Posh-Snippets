$sysInternalsKey = 'HKCU:\Software\SysInternals'
if (!(Test-Path -Path $sysInternalsKey))
{
	New-Item -Path $sysInternalsKey | Out-Null
}

New-ItemProperty "HKCU:\Software\Sysinternals" -Name "EulaAccepted" -Value 1 -PropertyType "DWORD" -Force | Out-Null
