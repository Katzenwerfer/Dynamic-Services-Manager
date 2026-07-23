function New-KillerTask {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$ProcessPath,
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$ScriptPath
    )

    $ProcessName = (Get-ChildItem -Path $ProcessPath -Force).Name
    $TaskName = "Killer Task ($ProcessName)"

    $TaskPath = '\Custom\'

    $ScheduledTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue

    if ($ScheduledTask) {
        Write-Warning -Message 'Scheduled task already exists. No action taken.'
        return
    }

    Write-Warning -Message 'Could not find the scheduled task.'
    Write-Host -Object 'Generating a new one...' -ForegroundColor Cyan

    # --------------------------------
    # === Scheduled Task Principal ===
    # --------------------------------

    $UserId = "$env:USERDOMAIN\$env:USERNAME"

    $ScheduledTaskPrincipal = New-ScheduledTaskPrincipal -UserId $UserId -LogonType S4U

    # -----------------------------
    # === Scheduled Task Action ===
    # -----------------------------

    $ActionProcess = '"C:\Program Files\PowerShell\7\pwsh.exe"'

    $ScriptContent = Get-Content -Path $ScriptPath -Raw
    $MinifiedContent = Compress-ScriptBlock -ScriptBlock ([ScriptBlock]::Create($ScriptContent))
    $UnicodeBytes = [System.Text.Encoding]::Unicode.GetBytes($MinifiedContent)
    $EncodedCommand = [System.Convert]::ToBase64String($UnicodeBytes)
    $ActionParameters = "-ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -EncodedCommand `"$EncodedCommand`""

    $ScheduledTaskAction = New-ScheduledTaskAction -Execute $ActionProcess -Argument $ActionParameters

    # -------------------------------
    # === Scheduled Task Settings ===
    # -------------------------------

    $ScheduledTaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew

    # ------------------------------
    # === Scheduled Task Trigger ===
    # ------------------------------

    $TargetQuery = @"
<QueryList>
    <Query Id="0" Path="Security">
        <Select Path="Security">
            *[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and
            (EventID=4689) and
            (Task=13313)]] and
            *[EventData[Data[@Name='ProcessName'] and
            (Data='$ProcessPath')]]
        </Select>
    </Query>
</QueryList>
"@

    $ScheduledTaskTrigger = Get-CimClass -ClassName 'MSFT_TaskEventTrigger' -Namespace 'Root/Microsoft/Windows/TaskScheduler' | New-CimInstance -ClientOnly
    $ScheduledTaskTrigger.Subscription = $TargetQuery

    # -------------------------------
    # === Scheduled Task Creation ===
    # -------------------------------

    $null = New-ScheduledTask -Action $ScheduledTaskAction -Principal $ScheduledTaskPrincipal -Settings $ScheduledTaskSettings -Trigger $ScheduledTaskTrigger | Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath

    # -----------------------------------
    # === Scheduled Task Verification ===
    # -----------------------------------

    $ScheduledTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue

    if (-not $ScheduledTask) {
        Write-Error -Message 'Failed to register scheduled task.' -ErrorAction Stop
    }

    Write-Host -Object "Successfully registered scheduled task." -ForegroundColor Green
}
