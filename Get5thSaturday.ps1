$year=2018
ForEach ($month in 1..12) { 
	$d = New-Object DateTime($year, $month, 1) #don't assume specific string date format
	$daysToSat = (7 + [System.DayOfWeek]::Saturday - $d.DayOfWeek.value__) % 7
	$d.AddDays(28 + $daysToSat) | where { $_.Month -eq $month }
}
