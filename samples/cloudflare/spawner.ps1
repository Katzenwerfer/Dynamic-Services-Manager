$Service = Get-Service -Name 'CloudflareWARP'

if ($Service.Status -ne 'Running') {
    Start-Service -Name 'CloudflareWARP'
}
