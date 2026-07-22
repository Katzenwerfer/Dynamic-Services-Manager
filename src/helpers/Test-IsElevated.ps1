$ObjectParameters = @{
    TypeName     = [System.Security.Principal.WindowsPrincipal]
    ArgumentList = [System.Security.Principal.WindowsIdentity]::GetCurrent()
}

$CurrentIdentity = New-Object @ObjectParameters

$AdministratorRole = [Security.Principal.WindowsBuiltInRole]::Administrator

$IsElevated = $CurrentIdentity.IsInRole($AdministratorRole)

if (-not $IsElevated) {
    Write-Error -Message "This script requires local admin privileges. Please run it as administrator." -ErrorAction 'Stop'
}
