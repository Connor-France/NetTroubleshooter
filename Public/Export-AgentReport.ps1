function Export-AgentReport {
    [CmdletBinding()]
    param(
        [int]$Tail = 50
    )

    $moduleRoot = Split-Path -Parent $PSScriptRoot
    $logRoot = Join-Path $moduleRoot 'Logs'
    $reportRoot = Join-Path $moduleRoot 'Reports'

    if (-not (Test-Path $logRoot)) {
        Write-Host "No Logs folder found. Run Invoke-Agent first." -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path $reportRoot)) {
        New-Item -ItemType Directory -Force -Path $reportRoot | Out-Null
    }

    $latestLog = Get-ChildItem -Path $logRoot -Filter '*.jsonl' |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latestLog) {
        Write-Host "No log files found. Run Invoke-Agent first." -ForegroundColor Yellow
        return
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
    $reportPath = Join-Path $reportRoot "NetTroubleshooter-Report-$timestamp.md"

    $entries = Get-Content -Path $latestLog.FullName -Tail $Tail |
        ForEach-Object {
            try {
                $_ | ConvertFrom-Json
            }
            catch {
                $null
            }
        } |
        Where-Object { $null -ne $_ }

    $report = New-Object System.Collections.Generic.List[string]

    $report.Add("# NetTroubleshooter Diagnostic Report")
    $report.Add("")
    $report.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $report.Add("")
    $report.Add("Source log: $($latestLog.FullName)")
    $report.Add("")
    $report.Add("Entries included: $($entries.Count)")
    $report.Add("")
    $report.Add("---")
    $report.Add("")

    foreach ($entry in $entries) {
        $report.Add("## $($entry.EventType)")
        $report.Add("")
        $report.Add("- Timestamp: $($entry.Timestamp)")
        $report.Add("- Scenario: $($entry.Scenario)")
        $report.Add("- Step: $($entry.StepNumber)")
        $report.Add("- Message: $($entry.Message)")

        if ($entry.Suggestion -and $entry.Suggestion.Command) {
            $report.Add("- Suggested command: $($entry.Suggestion.Command)")
        }

        if ($entry.Suggestion -and $entry.Suggestion.Reason) {
            $report.Add("- Reason: $($entry.Suggestion.Reason)")
        }

        if ($entry.Suggestion -and $entry.Suggestion.Risk) {
            $report.Add("- Risk: $($entry.Suggestion.Risk)")
        }

        if ($entry.Output) {
            $outputText = $entry.Output.ToString()

            if ($outputText.Length -gt 2000) {
                $outputText = $outputText.Substring(0, 2000) + "`n... output truncated in report ..."
            }

            $report.Add("")
            $report.Add("### Output")
            $report.Add("")
            $report.Add($outputText)
        }

        $report.Add("")
        $report.Add("---")
        $report.Add("")
    }

    $report | Set-Content -Path $reportPath -Encoding UTF8

    Write-Host ""
    Write-Host "Report exported:" -ForegroundColor Green
    Write-Host "  $reportPath"

    return $reportPath
}
