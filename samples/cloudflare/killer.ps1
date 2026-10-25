$SpawnerTask = Get-ScheduledTask -TaskName 'Spawner Task (Cloudflare WARP.exe)' -TaskPath '\Custom\'

if ($SpawnerTask.State -eq 'Running') {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (($SpawnerTask.State -eq 'Running') -and ($Stopwatch.ElapsedMilliseconds -lt 3000)) {
        [System.Threading.Thread]::Sleep(200)
        $SpawnerTask = Get-ScheduledTask -TaskName 'Spawner Task (Cloudflare WARP.exe)' -TaskPath '\Custom\'
    }
    $Stopwatch.Stop()
}

$ServiceNames = @(
    'CloudflareWARP',
    'CloudflareWARPUpdater'
)

Start-Sleep -Seconds 10

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
