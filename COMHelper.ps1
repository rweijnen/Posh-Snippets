$source = @'
using System;
using System.Runtime.InteropServices;

public class Ole32
{    
    [DllImport("ole32.dll")]
    public static extern int ProgIDFromCLSID([In()]ref Guid clsid, [MarshalAs(UnmanagedType.LPWStr)]out string lplpszProgID);

    [DllImport("ole32.dll")]
    public static extern int CLSIDFromProgID([MarshalAs(UnmanagedType.LPWStr)]string lpszProgID, out Guid lpcslid);
}
'@

Add-Type $source -ErrorAction:SilentlyContinue

function Get-ProgID {
  <#
  .SYNOPSIS
  Retrieves the ProgID for a given CLSID 
  .DESCRIPTION
  Retrieves the ProgID for a given CLSID 
  .EXAMPLE
  Get-ProgID "Word.Application","Excel.Application"
  .EXAMPLE
  Get-ProgID -ClassID "Word.Application","Excel.Application"
  .PARAMETER ClassId
  The Class ID (CLSID) for which you want to retrieve the Prog ID
  #>
 [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='The Class ID (Guid) for which you want to retreive the Prog ID')]
    [Alias('Guid')]
	[guid[]]$ClassId
   )
   
	begin 
	{
   		Write-Verbose "Retreiving Prog ID for $ClassId"
	}
	
	process
	{
		ForEach ($item in $ClassId)
		{
			Write-Verbose "Processing $item"
			[string]$progId = [string]::Empty

			$hr = [Ole32]::ProgIDFromCLSID([ref]$item, [ref]$progId)
			
			if ($hr -eq 0)
			{
				$progId						
			}
			else
			{
				throw New-Object System.ComponentModel.Win32Exception($hr)
			}
		}
	}
}
 
 
function Get-ClassID {
  <#
  .SYNOPSIS
  Retrieves the ProgID for a given CLSID 
  .DESCRIPTION
  Retrieves the ProgID for a given Class ID
  .EXAMPLE
  Get-ClassID "000209ff-0000-0000-c000-000000000046"
  .EXAMPLE
  #todo
  .PARAMETER ProgId
  The Program Id (ProgID) for which you want to retrieve the Class ID
  #>
 [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='The Progr ID for which you want to retreive the Class ID')]
    [string[]]$ProgId
   )
   
	begin 
	{
   		Write-Verbose "Retreiving Class Id for $ProgId"
	}
	
	process
	{
		ForEach ($item in $ProgId)
		{
			Write-Verbose "Processing $item"
			[Guid]$clsId = [Guid]::Empty

			$hr = [Ole32]::CLSIDFromProgId($item, [ref]$clsid)
			if ($hr -eq 0)
			{
				$clsid
			}
			else
			{
				throw New-Object System.ComponentModel.Win32Exception($hr)
			}
		}
	}
}

#examples: 
#Get-ClassID "Word.Application" 
#Get-ClassID "Word.Application" | Get-ProgID

