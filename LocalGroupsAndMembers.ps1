# Add a Members property to Get-LocalGroup
Update-TypeData -TypeName Microsoft.PowerShell.Commands.LocalGroup -MemberName Members -MemberType ScriptProperty -Value { 
  Get-LocalGroupMember -Group $this 
} -ErrorAction:SilentlyContinue
 
# List all Local Groups and their members
Get-LocalGroup | select Name, Members

# or export them...
Get-LocalGroup | Export-Clixml 'LocalGroups.xml'
