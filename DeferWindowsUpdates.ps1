$updateKey = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
$startDate = Get-Date ((Get-Date).AddYears(1))
$endDate = $startDate.AddDays(7)

function Format-DateString($date){
    (Get-Date $date -Format s) + 'Z'
}

if(Test-Path $updateKey){
    New-ItemProperty -Path $updateKey -Name PauseFeatureUpdatesEndTime -Value (Format-DateString $endDate) -PropertyType STRING -Force
    New-ItemProperty -Path $updateKey -Name PauseFeatureUpdatesStartTime -Value (Format-DateString $startDate) -PropertyType STRING -Force
    New-ItemProperty -Path $updateKey -Name PauseUpdatesExpiryTime -Value (Format-DateString $endDate) -PropertyType STRING -Force
}
