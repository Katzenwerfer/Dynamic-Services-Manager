Start-Sleep -Seconds 10

$SteamProcesses = Get-Process -Name 'steam'

$InputProcesses = $SteamProcesses | Where-Object -Property 'CommandLine' -Like '*steam://forceinputappid/*'

foreach ($Process in $InputProcesses) {
    if (-not $Process.Parent) {
        $Process | Stop-Process -Force
    }
}
