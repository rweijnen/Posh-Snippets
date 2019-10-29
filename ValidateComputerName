function Test-Computername {
	[OutputType('bool')]
    [CmdletBinding()]
    param (
    	[Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]$ComputerName      
    )
    
    Write-Debug "Testing $ComputerName"
    if ($ComputerName.Length -lt 1 -or $ComputerName.Length -gt 15)
    {
        Write-Verbose "Not allowed: $ComputerName"
        Write-Verbose "Length must be between 1 and 15 characters"
        
        return $false
    }

    $disallowedChars = @('\', '~', ':', '!', '@', '#', '$', '%', '^', '&', "'", '(', ')', '{', '}',' ')
    foreach ($c in $disallowedChars)
    {
        Write-Debug "Testing: $c"
        if ($ComputerName.Contains($c))
        {
            Write-Verbose "Not allowed: $c in $ComputerName"
            Write-Verbose "Disallowed characters are: $($disallowedChars -join '') see https://support.microsoft.com/en-us/help/909264/naming-conventions-in-active-directory-for-computers-domains-sites-and"
            
            return $false
        }
    }
    
    if ($ComputerName.EndsWith('-') -or $ComputerName.EndsWith('.'))
    {
        Write-Verbose "Not allowed: $ComputerName"
        Write-Verbose 'Computer names cannot end with - or .'
        
        return $false
    }

    if ($ComputerName.StartsWith('.'))
    {
        Write-Verbose "Not allowed: $ComputerName"
        Write-Verbose 'Computer names cannot start with .'
        
        return $false
    }


    if ($ComputerName.Length -eq 2)
    {
        $disallowedNames = @("AN", "AO", "AU", "BA", "BG", "BO", "BU", "CA", "CD", "CG", "CO", "DA", "DG", "DU", "EA", "ED", "HI", `
        "IU", "LA", "LG", "LS", "LW", "ME", "MU", "NO", "NS", "NU", "PA", "PO", "PS", "PU", "RC", "RD", "RE", "RO", "RS", "RU", `
         "SA", "SI", "SO", "SU", "SY", "WD")

         foreach ($name in $disallowedNames)
        {
            Write-Debug "Testing: $name"
            if ($ComputerName -eq $name)
            {
                Write-Verbose "Not allowed: $ComputerName"
                Write-Verbose '2-character SDDL user strings that are listed in well-known SIDs list cannot be used. Otherwise, "import", "export" and "take control" operations fail. See https://msdn.microsoft.com/en-us/library/windows/desktop/aa379602%28v=vs.85%29.aspx'
                Write-Verbose ($disallowedNames -join ',')
                return $false
            }
        }
    }

    Write-Verbose "$ComputerName is valid"
    return $true
}
