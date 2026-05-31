$source = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WinAPI {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
}
"@
Add-Type -TypeDefinition $source

$targetPid = 6120
$traeProc = Get-Process -Id $targetPid -ErrorAction SilentlyContinue
if (-not $traeProc) { Write-Host "Trae PID $targetPid not found"; exit }

$hWnd = $traeProc.MainWindowHandle
if ($hWnd -eq 0) { Write-Host "No main window handle"; exit }

$sb = New-Object System.Text.StringBuilder 256
[WinAPI]::GetWindowText($hWnd, $sb, 256) | Out-Null
Write-Host "Window title before: $($sb.ToString())"

$isMin = [WinAPI]::IsIconic($hWnd)
Write-Host "Minimized: $isMin"

[WinAPI]::ShowWindowAsync($hWnd, 9) | Out-Null
Start-Sleep 2
[WinAPI]::SetForegroundWindow($hWnd) | Out-Null
Start-Sleep 1

$sb2 = New-Object System.Text.StringBuilder 256
[WinAPI]::GetWindowText($hWnd, $sb2, 256) | Out-Null
Write-Host "Title after: $($sb2.ToString())"

$fgHwnd = [WinAPI]::GetForegroundWindow()
$fgSb = New-Object System.Text.StringBuilder 256
[WinAPI]::GetWindowText($fgHwnd, $fgSb, 256) | Out-Null
Write-Host "Foreground window: $($fgSb.ToString())"
if ($fgHwnd -eq $hWnd) { Write-Host "SUCCESS: Trae CN is now foreground!" }
