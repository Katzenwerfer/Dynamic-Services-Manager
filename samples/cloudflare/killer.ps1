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
