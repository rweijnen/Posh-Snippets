
# This script needs admin rights, be sure to run it elevated!

# This script fixes an issue between the new Microsoft Teams and the Nahimic service
# The issue is black screen instead of video/webcam unless minimised
# The script adds 2 processes to the BlackApps.dat file...


function Get-Directories
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   Position = 0)]
		[System.IO.FileInfo]$Path,
		[Parameter(Position = 1)]
		[String]$SearchPattern = '*.*'
	)
	
	Begin
	{
		# an arraylist to hold the results
		$result = New-Object -TypeName System.Collections.ArrayList
		
		# a stack object to push directories that needs to be processed
		$pending = New-Object System.Collections.Generic.Stack[String]
		
	}
	Process
	{
		# push all provided paths to the stack
		foreach ($entry in $Path)
		{
			$pending.Push($entry)
		}
		
		# loop through the stack
		while ($pending.Count -ne 0)
		{
			# current item to process
			$current = $pending.Pop()
			try
			{
				# get all subdirectories from the current one
				# handle in try..catch e.g. to catch Access Denied
				$next = [IO.Directory]::GetDirectories($current, $SearchPattern)
				if ($null -ne $next)
				{
					ForEach ($dir in $next)
					{
						# add directory to the result list
						[void]$result.Add($dir)
					}
				}
			}
			# ignore exceptions
			catch { }
			
			try
			{
				# we need to call GetDirectories for all directories that we found
				$next = [IO.Directory]::GetDirectories($current, $SearchPattern)
				ForEach ($dir in $next)
				{
					# push subdir to stack
					$pending.Push($dir)
				}
			}
			# ignore exceptions
			catch { }
		}
		
	}
	End
	{
		return $result	
	}
}

function Find-BlackAppsDat {
    # Get the ProgramData path dynamically
    $programDataPath = [Environment]::GetFolderPath('CommonApplicationData')
	 
	 $activity = "Searching for BlackApps.dat"
	 # get list of folders to search...
	 # note using Get-Directories as Get-ChildItem bombs out on errors...
	 $folders = Get-Directories -Path ([System.IO.FileInfo]$programDataPath) | Sort-Object

	 for ($i= 0 ; $i -lt $folders.Count ; $i++)
	 {
	    try 
		 {
	        	# Search for BlackApps.dat
				$percentComplete = [int] [Math]::Truncate(($i / $folders.Count) * 100)
				Write-Progress -Activity $activity -CurrentOperation $folders[$i] -PercentComplete $percentComplete
        		$file = Get-ChildItem -Path $folders[$i] -Filter "BlackApps.dat" -ErrorAction Stop
				if ($null -ne $file)
				{
					break
				}
	   } 
		catch 
		{
        		# ignore exception (e.g. access denied) so we can continue to next folder...
  		}
   }

	Write-Progress -Activity $activity -Completed
	if ($null -ne $file)
	{
   	return $file.FullName
	}
}

$blackAppsDatPath = Find-BlackAppsDat
if ($null -ne $blackAppsDatPath)
{
	$fileChanged = $false
	"Found BlackApps.dat at $blackAppsDatPath"
   # Read the file content
   $fileContent = Get-Content -Path $blackAppsDatPath

	$processNames = @("ms-teams.exe", "msedgewebview2.exe")
   # Check if the process name is already in the file
   foreach ($processName in $processNames)
	{
		if ($processName -notin $fileContent) {
	       # Add the process name to the file
	       $fileContent += $processName
			 $fileChanged = $true
	       Write-Host "$processName added to the file."
	   } else {
	       Write-Host "$processName is already in the file."
	   }
	}
	
	if ($fileChanged)
	{
		$fileContent | Out-File -FilePath $blackAppsDatPath
		$serviceName = 'NahimicService'
		"Restarting Service $serviceName to update changes..."
		Restart-Service -Name $serviceName -Confirm
	}
}
else
{
	"BlackApps.data was not found!"
}




