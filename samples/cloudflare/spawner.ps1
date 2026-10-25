$Service = Get-Service -Name 'CloudflareWARP'

if ($Service.Status -ne 'Running') {
    Start-Service -Name 'CloudflareWARP'
}

$Task = Get-ScheduledTask -TaskName 'CloudflareWARPServiceRecovery'

if ($task.State -ne 'Disabled') {
    Disable-ScheduledTask -TaskName 'CloudflareWARPServiceRecovery'
}
