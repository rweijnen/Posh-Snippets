$lolDriversUri = 'https://www.loldrivers.io/api/drivers.json'
$scanPath = "$env:windir\System32"

"Fetching loldriver list as json from $lolDriversUri"
$response = Invoke-RestMethod -Uri $lolDriversUri

"Obtained driver list from loldrivers.io, count is $($response.Count)"

"Scanning $scanPath for drivers (*.sys)"
$driverList = Get-ChildItem -Path $scanPath -Recurse -Filter "*.sys" -ErrorAction SilentlyContinue | Select-Object Name, FullName
"Found $($driverList.Count) drivers"

ForEach ($driver in $driverList)
{
	if ($response.name.Contains($driver.Name))
	{
		"Found: $($driver.Name) at $($driver.FullName)"
	}
}
