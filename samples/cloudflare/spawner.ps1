$ServiceNames = @(
    'CloudflareWARP',
    'CloudflareWARPUpdater'
)

foreach ($ServiceName in $ServiceNames) {
    $Service = Get-Service -Name $ServiceNames

    $ServiceStatus = $Service.Status

    if ($ServiceStatus -ne 'Running') {
        $Service | Start-Service
    }
}
