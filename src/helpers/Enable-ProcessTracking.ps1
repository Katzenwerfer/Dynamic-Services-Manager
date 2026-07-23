$SubcategoryNames = @(
    'Process Creation',
    'Process Termination'
)

foreach ($SubcategoryName in $SubcategoryNames) {
    $Subcategory = & auditpol.exe /get /subcategory:"$SubcategoryName" /r | ConvertFrom-Csv
    $Status = $Subcategory | Select-Object -ExpandProperty 'Inclusion Setting'

    if ($Status -like '*Success*') {
        Write-Warning -Message "$SubcategoryName tracking is enabled already. No action taken."
        continue
    }

    Write-Warning -Message "$SubcategoryName tracking is disabled."
    Write-Host -Object "Enabling $SubcategoryName tracking..." -ForegroundColor Cyan

    $null = & auditpol.exe /set /subcategory:"$SubcategoryName" /success:enable

    $Subcategory = & auditpol.exe /get /subcategory:"$SubcategoryName" /r | ConvertFrom-Csv
    $Status = $Subcategory | Select-Object -ExpandProperty 'Inclusion Setting'

    if ($Status -notlike '*Success*') {
        Write-Error -Message "Failed to enable $SubcategoryName tracking." -ErrorAction Stop
    }

    Write-Host -Object "$SubcategoryName tracking enabled successfully." -ForegroundColor Green
}
