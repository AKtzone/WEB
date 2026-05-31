$targetPid = 2156
$traeProc = Get-Process -Id $targetPid -ErrorAction SilentlyContinue

if (-not $traeProc) {
    Write-Host "PID $targetPid no longer exists"
    Write-Host "Searching for Trae-like processes..."
    $all = Get-Process
    foreach ($p in $all) {
        $n = $p.ProcessName
        $h = $p.MainWindowHandle
        $mh = $p.MainModule.FileName
        if ($mh -like "*TRAE*" -or $mh -like "*Trae*" -or $n -like "*TRAE*") {
            Write-Host "Found: $n (PID $($p.Id)) Handle=$h Exe=$mh"
        }
    }
    exit
}

$hWnd = $traeProc.MainWindowHandle
Write-Host "PID $targetPid exists: $($traeProc.ProcessName)"
Write-Host "MainWindowHandle: $hWnd"
Write-Host "StartTime: $($traeProc.StartTime)"
Write-Host "Responding: $($traeProc.Responding)"

# Show all threads/windows for this process
$threads = $traeProc.Threads
Write-Host "Threads: $($threads.Count)"

# Try to find ANY top-level window owned by this process
Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class EW {
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
}
'@

$windows = New-Object System.Collections.ArrayList
$procCallback = {
    param($hWnd, $lParam)
    $pidVal = 0
    [EW]::GetWindowThreadProcessId($hWnd, [ref]$pidVal) | Out-Null
    if ($pidVal -eq $targetPid) {
        $sb = New-Object System.Text.StringBuilder 256
        [EW]::GetWindowText($hWnd, $sb, 256) | Out-Null
        $text = $sb.ToString()
        if ($text -ne "") {
            $windows.Add(@{Handle=$hWnd; Title=$text}) | Out-Null
        }
    }
    return $true
}

[EW]::EnumWindows($procCallback, [IntPtr]::Zero) | Out-Null

if ($windows.Count -eq 0) {
    Write-Host "No visible windows with title found for this PID"
    Write-Host "Try launching fresh..."
    $exePath = "D:\腾讯电脑管家软件搬家\软件搬家\TRAE SOLO CN (User)\TRAE SOLO CN.exe"
    $projPath = "D:\Project\WEB\swiss-army-knife"
    Stop-Process -Id $targetPid -Force
    Start-Sleep 2
    Write-Host "Killed old process, launching fresh..."
    Start-Process -FilePath $exePath -ArgumentList $projPath
    Start-Sleep 8
    # Check again
    $newProcs = Get-Process | Where-Object { $_.ProcessName -like "*TRAE*" -or $_.ProcessName -like "*Trae*" }
    foreach ($np in $newProcs) {
        Write-Host "New process: $($np.ProcessName) PID=$($np.Id) Handle=$($np.MainWindowHandle) Start=$($np.StartTime.ToString('HH:mm:ss'))"
        if ($np.MainWindowHandle -ne 0) {
            $sb2 = New-Object System.Text.StringBuilder 256
            [EW]::GetWindowText($np.MainWindowHandle, $sb2, 256) | Out-Null
            Write-Host "  Title: $($sb2.ToString())"
        }
    }
} else {
    Write-Host "Found $($windows.Count) windows:"
    foreach ($w in $windows) {
        Write-Host "  Handle=$($w.Handle) Title='$($w.Title)'"
    }
}
