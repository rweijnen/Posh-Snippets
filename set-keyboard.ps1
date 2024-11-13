# Set the desired keyboard layout and language code
$desiredLayout = "00020409" # United States-International layout
$desiredLanguage = "en-US"

# Add the United States-International layout
$languageList = New-WinUserLanguageList -Language $desiredLanguage
Set-WinUserLanguageList $languageList -Force
Set-WinUILanguageOverride -Language $desiredLanguage
Set-WinDefaultInputMethodOverride -InputTip $desiredLayout

# Remove all other keyboard layouts
$currentLanguages = Get-WinUserLanguageList | Where-Object { $_.InputMethodTips -contains $desiredLayout }
if ($currentLanguages) {
    Set-WinUserLanguageList $currentLanguages -Force
} else {
    Write-Output "No matching keyboard layouts found to set."
}

# Disable the Language Bar, creating the registry path if needed
$path = "HKCU:\Software\Microsoft\CTF\LangBar"
if (!(Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}
Set-ItemProperty -Path $path -Name "ShowStatus" -Value 3

# Restart Explorer to apply changes (optional, can be removed if not needed)
Stop-Process -Name explorer -Force
Start-Process explorer
