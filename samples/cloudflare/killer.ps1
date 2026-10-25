$SpawnerTask = Get-ScheduledTask -TaskName 'Spawner Task (Cloudflare WARP.exe)' -TaskPath '\Custom\'

if ($SpawnerTask.State -eq 'Running') {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (($SpawnerTask.State -eq 'Running') -and ($Stopwatch.ElapsedMilliseconds -lt 3000)) {
        [System.Threading.Thread]::Sleep(200)
        $SpawnerTask = Get-ScheduledTask -TaskName 'Spawner Task (Cloudflare WARP.exe)' -TaskPath '\Custom\'
    }
    $Stopwatch.Stop()
}

$CloudflareProcess = Get-Process -Name 'Cloudflare WARP'

if ($CloudflareProcess) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (($CloudflareProcess) -and ($Stopwatch.ElapsedMilliseconds -lt 3000)) {
        [System.Threading.Thread]::Sleep(200)
        $CloudflareProcess = Get-Process -Name 'Cloudflare WARP'
    }
    $Stopwatch.Stop()
}

if (-not $CloudflareProcess) {
    $Task = Get-ScheduledTask -TaskName 'CloudflareWARPServiceRecovery'

    if ($task.State -ne 'Disabled') {
        Disable-ScheduledTask -TaskName 'CloudflareWARPServiceRecovery'
    }

    $ServiceNames = @(
        'CloudflareWARP',
        'CloudflareWARPUpdater'
    )

    foreach ($ServiceName in $ServiceNames) {
        $Service = Get-Service -Name $ServiceName

        if ($Service.StartType -ne 'Manual') {
            Set-Service -Name $ServiceName -StartupType Manual
        }

        $ServiceStatus = $Service.Status

        if ($ServiceStatus -eq 'Running') {
            Stop-Service -Name $ServiceName -Force
        }
    }
}
