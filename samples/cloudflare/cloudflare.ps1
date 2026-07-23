if (-not (Get-Command -Name New-SpawnerTask -ErrorAction SilentlyContinue)) {
    $PSSpawnerPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\functions\New-SpawnerTask.ps1' -Resolve
    . $PSSpawnerPath
}

$parameters = @{
    ProcessPath = 'C:\Program Files\Cloudflare\Cloudflare WARP\Cloudflare WARP.exe'
    ScriptPath  = Join-Path -Path $PSScriptRoot -ChildPath 'spawner.ps1' -Resolve
}

New-SpawnerTask @parameters

if (-not (Get-Command -Name New-KillerTask -ErrorAction SilentlyContinue)) {
    $PSKillerPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\functions\New-KillerTask.ps1'
    . $PSKillerPath
}

$parameters = @{
    ProcessPath = 'C:\Program Files\Cloudflare\Cloudflare WARP\Cloudflare WARP.exe'
    ScriptPath  = Join-Path -Path $PSScriptRoot -ChildPath 'killer.ps1' -Resolve
}

New-KillerTask @parameters
