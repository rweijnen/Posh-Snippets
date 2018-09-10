cls
# fixes DCOM permissions based on eventlog errors

Import-Module DCOMPermissions.psm1
Install-Module -Name NtObjectManager

Stop-Service TrustedInstaller
Start-Service TrustedInstaller
$tipid = get-process TrustedInstaller | select -expand id
$token = Get-NtTokenFromProcess -ProcessId $tipid
$current = Get-NtThread -Current -PseudoHandle
$imp = $current.Impersonate($token)
$imp_token = Get-NtToken -Impersonation
$imp_token.Groups

$components = Get-WMIObject Win32_DCOMApplicationSetting
$events = Get-WinEvent -FilterHashtable  @{LogName='System'; ProviderName='Microsoft-Windows-DistributedCOM'; Level=2; StartTime=(Get-Date).AddDays(-1)}
ForEach ($event in $events)
{
	$msg = $event.Message -replace "`r`n", ""
	if ($msg -match 'CLSID (?<CLSID>\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}).*APPID (?<AppId>\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}).*user (?<User>[^\(]*) SID \((?<SID>[^\)]*).*from address (?<Address>[^ \(]*) \(Using (?<Protocol>[^ \)]*)')
	{
		$DcomPerm = Get-DComPermission -ApplicationID $Matches.AppId -Type "Launch"
		Grant-DComPermission -ApplicationID $Matches.AppId -Type "Launch" -Account $Matches.User -Permissions LocalLaunch,LocalActivation -Verbose
		""
	}
}
