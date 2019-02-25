$errorReportingKeyUser = 'HKCU:\Software\Microsoft\Windows\Windows Error Reporting'
$errorReportingKeyMachine = 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting'

if(Test-Path $errorReportingKeyUser){
    New-ItemProperty -Path $errorReportingKeyUser -Name Disabled -Value 0 -PropertyType DWORD -Force
}

if(Test-Path $errorReportingKeyMachine){
    New-ItemProperty -Path $errorReportingKeyMachine -Name Disabled -Value 0 -PropertyType DWORD -Force
}