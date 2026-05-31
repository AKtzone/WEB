Write-Host "=== Closing wrong Trae instances ==="

# Kill all TRAE SOLO CN processes (they show installer dialog)
$soloProcs = Get-Process -Name "TRAE SOLO CN" -ErrorAction SilentlyContinue
Write-Host "Found $($soloProcs.Count) TRAE SOLO CN processes"
foreach ($p in $soloProcs) {
    Write-Host "  Killing PID $($p.Id)..."
    $p.Kill()
}

Start-Sleep 2
Write-Host "`n=== Launching correct Trae CN ==="

$traeCnPath = "D:\Trae CN\Trae CN\Trae CN.exe"
$projectPath = "D:\Project\WEB\swiss-army-knife"

if (-not (Test-Path $traeCnPath)) {
    Write-Host "ERROR: Trae CN not found at $traeCnPath"
    exit 1
}

Start-Process -FilePath $traeCnPath -ArgumentList $projectPath
Write-Host "Launch command sent!"
Start-Sleep 8

# Check for Trae CN processes
$cnProcs = Get-Process -Name "Trae CN" -ErrorAction SilentlyContinue
$cnProcs2 = Get-Process -Name "TraeCN" -ErrorAction SilentlyContinue
Write-Host "`nTrae CN processes (name=Trae CN): $($cnProcs.Count)"
Write-Host "Trae CN processes (name=TraeCN): $($cnProcs2.Count)"

# Check all new processes
$all = Get-Process
foreach ($p in $all) {
    $n = $p.ProcessName
    if ($n -like "*Trae*" -or $n -like "*trae*") {
        Write-Host "  $n PID=$($p.Id) Handle=$($p.MainWindowHandle)"
    }
}
