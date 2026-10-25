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
    $ServiceNames = @(
        'CloudflareWARP',
        'CloudflareWARPUpdater'
    )

    foreach ($ServiceName in $ServiceNames) {
        $Service = Get-Service -Name $ServiceName

        $ServiceStartType = $Service.StartType

        if ($ServiceStartType -ne 'Manual') {
            $ServiceName | Set-Service -StartupType Manual
        }

        $ServiceStatus = $Service.Status

        if ($ServiceStatus -eq 'Running') {
            $Service | Stop-Service -Force
        }
    }
}
