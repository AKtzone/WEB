Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WinAPI {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
}
'@

$procs = Get-Process
$traeProc = $null
foreach ($p in $procs) {
    $n = $p.ProcessName
    if ($n -like "*TRAE*" -or $n -like "*Trae*" -or $n -like "*trae*") {
        $traeProc = $p
        break
    }
}

if (-not $traeProc) {
    Write-Host "ERROR: Trae not running"
    exit 1
}

$hWnd = $traeProc.MainWindowHandle
if ($hWnd -eq 0) {
    Write-Host "ERROR: No main window handle (possibly running in background)"
    exit 1
}

$isMin = [WinAPI]::IsIconic($hWnd)
Write-Host "Trae PID: $($traeProc.Id), Handle: $hWnd, Minimized: $isMin"

# Restore and bring to foreground
[WinAPI]::ShowWindowAsync($hWnd, 9) | Out-Null
Start-Sleep 1
[WinAPI]::SetForegroundWindow($hWnd) | Out-Null
Start-Sleep 1

$sb = New-Object System.Text.StringBuilder 256
[WinAPI]::GetWindowText($hWnd, $sb, 256) | Out-Null
Write-Host "Window title: $($sb.ToString())"

# Check if we successfully brought it to foreground
$fgHwnd = [WinAPI]::GetForegroundWindow()
$fgSb = New-Object System.Text.StringBuilder 256
[WinAPI]::GetWindowText($fgHwnd, $fgSb, 256) | Out-Null
Write-Host "Foreground window: $($fgSb.ToString())"
