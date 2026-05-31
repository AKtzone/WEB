$traePath = "D:\腾讯电脑管家软件搬家\软件搬家\TRAE SOLO CN (User)\TRAE SOLO CN.exe"
$projectPath = "D:\Project\WEB\swiss-army-knife"

function Find-TraeProcess {
    $procs = Get-Process
    $traeProcs = @()
    foreach ($p in $procs) {
        $name = $p.ProcessName
        if ($name -like "*TRAE*" -or $name -like "*Trae*" -or $name -like "*trae*") {
            $traeProcs += $p
        }
    }
    return $traeProcs
}

$existing = Find-TraeProcess
if ($existing.Count -gt 0) {
    Write-Host "Trae already running, PID: $($existing[0].Id)"
} else {
    Write-Host "Launching Trae CN..."
    Start-Process -FilePath $traePath -ArgumentList $projectPath
    Start-Sleep 5
    $newProc = Find-TraeProcess
    if ($newProc.Count -gt 0) {
        Write-Host "SUCCESS: Trae started, PID: $($newProc[0].Id)"
    } else {
        Write-Host "Trae process not found by name. Checking if any new process launched..."
        $all = Get-Process | Sort-Object StartTime -Descending | Select-Object -First 10
        foreach ($a in $all) { Write-Host "$($a.StartTime.ToString('HH:mm:ss')) $($a.Id) $($a.ProcessName)" }
    }
}
