$Service = Get-Service -Name 'ZeroTierOneService'

if ($Service.Status -ne 'Running') {
    Start-Service -Name 'ZeroTierOneService'
}
