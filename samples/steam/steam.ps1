if (-not (Get-Command -Name New-KillerTask -ErrorAction SilentlyContinue)) {
    $PSKillerPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\functions\New-KillerTask.ps1' -Resolve
    . $PSKillerPath
}

$parameters = @{
    ProcessPath  = 'C:\Program Files (x86)\Steam\steam.exe'
    ScriptPath   = Join-Path -Path $PSScriptRoot -ChildPath 'killer.ps1' -Resolve
    StopExisting = $true
}

New-KillerTask @parameters
