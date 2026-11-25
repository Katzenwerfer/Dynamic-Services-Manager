$SpawnerTask = Get-ScheduledTask -TaskName 'Spawner Task (zerotier_desktop_ui.exe)' -TaskPath '\Custom\'

if ($SpawnerTask.State -eq 'Running') {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (($SpawnerTask.State -eq 'Running') -and ($Stopwatch.ElapsedMilliseconds -lt 3000)) {
        [System.Threading.Thread]::Sleep(200)
        $SpawnerTask = Get-ScheduledTask -TaskName 'Spawner Task (zerotier_desktop_ui.exe)' -TaskPath '\Custom\'
    }
    $Stopwatch.Stop()
}

$ZeroTierProcess = Get-Process -Name 'zerotier_desktop_ui' -ErrorAction SilentlyContinue

if ($ZeroTierProcess) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (($ZeroTierProcess) -and ($Stopwatch.ElapsedMilliseconds -lt 3000)) {
        [System.Threading.Thread]::Sleep(200)
        $ZeroTierProcess = Get-Process -Name 'zerotier_desktop_ui' -ErrorAction SilentlyContinue
    }
    $Stopwatch.Stop()
}

if (-not $ZeroTierProcess) {
    $ServiceName = 'ZeroTierOneService'
    $Service = Get-Service -Name $ServiceName

    if ($Service.StartType -ne 'Manual') {
        Set-Service -Name $ServiceName -StartupType Manual
    }

    if ($Service.Status -eq 'Running') {
        Stop-Service -Name $ServiceName -Force
    }
}
