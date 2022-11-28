Add-Type -assembly "Microsoft.Office.Interop.Outlook"
$outlook = New-Object -ComObject Outlook.Application
$namespace = $Outlook.GetNameSpace("MAPI")
$calendar = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderCalendar)
ForEach ($appt in $calendar.Items)
{
    # change organizer name and/or subject word here....
    if ($appt.Organizer -ne 'Weijnen, Remko' -and $appt.Subject.Contains('OOTO'))
    {
        if ($appt.BusyStatus -ne 0)
        {
            $appt.BusyStatus = 0
            $appt.Save()
        }
        if ($appt.ReminderSet)
        {
            $appt.ReminderSet = $false
            $appt.Save()
        }

        "Subject    : $($appt.Subject)" 
        "Busy Status: $($appt.BusyStatus)" 
        "Reminder   : $($appt.ReminderSet)" 
    }
}
