Write-Host "=== Searching for Trae CN on D: drive ==="

# Check common locations
$searchPaths = @(
    "D:\Trae CN\*.exe",
    "D:\Trae\*.exe",
    "D:\Program Files\Trae*\*.exe",
    "D:\Program Files\ByteDance\*.exe",
    "D:\apps\Trae*\*.exe",
    "D:\THING\*.exe",
    "D:\腾讯电脑管家*\*\*TRAE*\*.exe",
    "D:\Project\WEB\swiss-army-knife\*.exe"
)

foreach ($p in $searchPaths) {
    $results = Get-ChildItem -Path $p -ErrorAction SilentlyContinue
    foreach ($r in $results) {
        Write-Host "Found: $($r.FullName) ($($r.Length/1MB -as [int]) MB)"
    }
}

Write-Host "`n=== Broader search ==="
$dirs = Get-ChildItem "D:\" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Trae*" -or $_.Name -like "*trae*" -or $_.Name -like "*TRAE*" }
foreach ($d in $dirs) {
    Write-Host "Dir: $($d.FullName)"
    $exes = Get-ChildItem "$($d.FullName)\*.exe" -ErrorAction SilentlyContinue
    foreach ($e in $exes) { Write-Host "  EXE: $($e.Name)" }
}

# Also check Start Menu shortcuts
Write-Host "`n=== Start Menu ==="
$startMenu = [Environment]::GetFolderPath("StartMenu")
$startMenuShortcuts = Get-ChildItem "$startMenu\Programs\*trae*" -Recurse -ErrorAction SilentlyContinue
foreach ($s in $startMenuShortcuts) {
    Write-Host "Shortcut: $($s.FullName)"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($s.FullName)
    Write-Host "  Target: $($shortcut.TargetPath)"
    Write-Host "  Args: $($shortcut.Arguments)"
}
