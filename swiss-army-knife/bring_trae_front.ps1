Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WinAPI {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
'@

# Find Trae windows with handle
$windows = New-Object System.Collections.ArrayList
$callback = {
    param($hWnd, $lParam)
    $pidVal = 0
    [WinAPI]::GetWindowThreadProcessId($hWnd, [ref]$pidVal) | Out-Null
    $sb = New-Object System.Text.StringBuilder 256
    [WinAPI]::GetWindowText($hWnd, $sb, 256) | Out-Null
    $text = $sb.ToString()
    if ($text -ne "" -and ($text -like "*TRAE*" -or $text -like "*Trae*")) {
        $rect = New-Object WinAPI+RECT
        [WinAPI]::GetWindowRect($hWnd, [ref]$rect) | Out-Null
        $w = $rect.Right - $rect.Left
        $h = $rect.Bottom - $rect.Top
        $windows.Add(@{Handle=$hWnd; Title=$text; Pid=$pidVal; W=$w; H=$h}) | Out-Null
    }
    return $true
}

[WinAPI]::EnumWindows($callback, [IntPtr]::Zero) | Out-Null

if ($windows.Count -eq 0) {
    Write-Host "No Trae windows found"
    exit
}

Write-Host "Found $($windows.Count) Trae windows:"
foreach ($w in $windows) {
    Write-Host "  PID=$($w.Pid) Handle=$($w.Handle) '$($w.Title)' ($($w.W)x$($w.H))"
}

# Use the first visible window
$target = $windows[0]
$hWnd = $target.Handle

# Check if minimized
$isMin = [WinAPI]::IsIconic($hWnd)
Write-Host "`nTarget window: '$($target.Title)' (PID $($target.Pid))"
Write-Host "Minimized: $isMin"
Write-Host "Size: $($target.W)x$($target.H)"

# Restore if needed, then foreground
if ($isMin) { [WinAPI]::ShowWindowAsync($hWnd, 9) | Out-Null; Start-Sleep 1 }
[WinAPI]::SetForegroundWindow($hWnd) | Out-Null
Start-Sleep 1

# Verify
$fgHwnd = [WinAPI]::GetForegroundWindow()
$fgSb = New-Object System.Text.StringBuilder 256
[WinAPI]::GetWindowText($fgHwnd, $fgSb, 256) | Out-Null
Write-Host "Foreground now: '$($fgSb.ToString())'"
if ($fgHwnd -eq $hWnd) { Write-Host "SUCCESS: Trae is now in foreground!" }
else { Write-Host "WARNING: Could not bring Trae to front (fg=$fgHwnd vs target=$hWnd)" }
