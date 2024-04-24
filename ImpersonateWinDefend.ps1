# uses NtObjectManager module
# quick example code to craft a token containging WinDefend, TrustedInstaller and Sense token...
# https://github.com/rweijnen/Posh-Snippets/blob/master/ImpersonateWinDefend.ps1


# First get SYSTEM token via Winlogon

# get winlogon pid
$winLogonPid = (get-process winlogon).id

# get winlogon token
$winLogonToken = Get-NtTokenFromProcess $winLogonPid

# impersonate winlogon
$current = Get-NtThread -Current -PseudoHandle
$contextWinLogon = $current.Impersonate($winLogonToken)

# Then get LSASS token to get more privileges
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

# enable all privileges, just because we can and might be useful for future purposes
$tokenParams = @{
    User = 'SY'  # SYSTEM
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
        'BA',           #BUILTIN\ADMINISTRATORS
        'WD',           #EVERYONE
        'S-1-5-6',      #NT AUTHORITY\SERVICE
        'S-1-5-11',     #NT AUTHORITY\Authenticated Users 
        'S-1-5-15',     #NT AUTHORITY\This Organization
        'S-1-5-32-545', #BUILTIN\Users 
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
