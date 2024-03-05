# a very annoying issue is that when Outlook wants to reauthenticate (to Office365) using this nicely looking "Modern Authentication Dialog"
# this dialog doesn't have a taskbar button and sometimes it's hidden behind Outlook itself making it appear as if Outlook hangs
# it also means the window cannot be brought to front with Alt-Tab
# below script gives it a taskbar button and brings it to front...

Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32 {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

        public const int GWL_EXSTYLE = -20;
        public const int WS_EX_APPWINDOW = 0x00040000;
    }
"@

function BringWindowToForeground($className) {
    $hwnd = [IntPtr]::Zero

    do {
        $hwnd = [Win32]::FindWindowEx([IntPtr]::Zero, $hwnd, $className, $null)
        if ($hwnd -ne [IntPtr]::Zero) {
            $exStyle = [Win32]::GetWindowLong($hwnd, [Win32]::GWL_EXSTYLE)
            # Ensure it has a taskbar button by adding WS_EX_APPWINDOW if necessary
            if (-not ($exStyle -band [Win32]::WS_EX_APPWINDOW)) {
                [Win32]::SetWindowLong($hwnd, [Win32]::GWL_EXSTYLE, $exStyle -bor [Win32]::WS_EX_APPWINDOW)
            }
            # Bring the window to the foreground
            [Win32]::SetForegroundWindow($hwnd)
        }
    }
    while ($hwnd -ne [IntPtr]::Zero)
}

# Replace 'OneAuthOLEBrowser' with the actual class name of your target window
BringWindowToForeground "OneAuthOLEBrowser"
