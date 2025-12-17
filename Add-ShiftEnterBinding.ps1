# Add Shift+Enter keybinding to Windows Terminal
# This script finds the Windows Terminal settings.json dynamically and adds the keybinding if not present

$ErrorActionPreference = "Stop"

# Find Windows Terminal using Get-AppxPackage
$wtPackage = Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue
if (-not $wtPackage) {
    # Try Preview version
    $wtPackage = Get-AppxPackage -Name "Microsoft.WindowsTerminalPreview" -ErrorAction SilentlyContinue
}

if (-not $wtPackage) {
    Write-Error "Windows Terminal not found. Please install it from the Microsoft Store."
    exit 1
}

$localAppData = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
$settingsPath = Join-Path $localAppData "Packages\$($wtPackage.PackageFamilyName)\LocalState\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Error "Settings file not found at: $settingsPath"
    exit 1
}

Write-Host "Found settings file: $settingsPath"

# Read the settings file
$settingsContent = Get-Content -Path $settingsPath -Raw

# Remove comments (Windows Terminal settings.json allows // comments)
$jsonWithoutComments = $settingsContent -replace '(?m)^\s*//.*$', '' -replace '//[^"]*$', ''

try {
    $settings = $jsonWithoutComments | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse settings.json: $_"
    exit 1
}

# Check for existing shift+enter binding in keybindings array (new schema)
if ($settings.keybindings) {
    $existingKeybinding = $settings.keybindings | Where-Object { $_.keys -eq "shift+enter" }
    if ($existingKeybinding) {
        Write-Host "Shift+Enter keybinding already configured in keybindings array. No changes made."
        exit 0
    }
}

# Check for existing shift+enter binding in actions array (old schema)
if ($settings.actions) {
    $existingAction = $settings.actions | Where-Object { $_.keys -eq "shift+enter" }
    if ($existingAction) {
        Write-Host "Shift+Enter keybinding already configured in actions array. No changes made."
        exit 0
    }
}

# Backup the original file
$backupPath = "$settingsPath.backup"
Copy-Item -Path $settingsPath -Destination $backupPath -Force
Write-Host "Backup created: $backupPath"

# Generate a unique action ID
$actionId = "User.sendInput." + [guid]::NewGuid().ToString("N").Substring(0, 8).ToUpper()

# Create the action definition
$newAction = @{
    command = @{
        action = "sendInput"
        input = "`n"
    }
    id = $actionId
}

# Create the keybinding
$newKeybinding = @{
    id = $actionId
    keys = "shift+enter"
}

# Initialize arrays if they don't exist
if (-not $settings.actions) {
    $settings | Add-Member -NotePropertyName "actions" -NotePropertyValue @()
}
if (-not $settings.keybindings) {
    $settings | Add-Member -NotePropertyName "keybindings" -NotePropertyValue @()
}

# Add the action and keybinding
$settings.actions = @($settings.actions) + $newAction
$settings.keybindings = @($settings.keybindings) + $newKeybinding

# Write the updated settings
$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host "Successfully added Shift+Enter keybinding to Windows Terminal."
Write-Host "Restart Windows Terminal for changes to take effect."
