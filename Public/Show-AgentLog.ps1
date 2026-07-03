function Show-AgentLog {
    [CmdletBinding()]
    param(
        [int]$Tail = 20
    )

    $moduleRoot = Split-Path -Parent $PSScriptRoot
    $logRoot = Join-Path $moduleRoot 'Logs'

    if (-not (Test-Path $logRoot)) {
        Write-Host "No Logs folder found." -ForegroundColor Yellow
        return
    }

    $latestLog = Get-ChildItem -Path $logRoot -Filter '*.jsonl' |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latestLog) {
        Write-Host "No log files found." -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "Latest NetTroubleshooter log:" -ForegroundColor Cyan
    Write-Host "  $($latestLog.FullName)"
    Write-Host ""

    Get-Content -Path $latestLog.FullName -Tail $Tail |
        ForEach-Object {
            try {
                $entry = $_ | ConvertFrom-Json

                $timestamp = $entry.Timestamp
                $scenario = $entry.Scenario
                $eventType = $entry.EventType
                $message = $entry.Message

                Write-Host "[$timestamp] [$scenario] $eventType" -ForegroundColor Green

                if ($message) {
                    Write-Host "  $message"
                }

                if ($entry.Suggestion -and $entry.Suggestion.Command) {
                    Write-Host "  Command: $($entry.Suggestion.Command)" -ForegroundColor DarkCyan
                }

                if ($entry.Suggestion -and $entry.Suggestion.Reason) {
                    Write-Host "  Reason : $($entry.Suggestion.Reason)" -ForegroundColor DarkGray
                }

                Write-Host ""
            }
            catch {
                Write-Host "Could not parse log line:" -ForegroundColor Red
                Write-Host $_
            }
        }
}
