function Invoke-Agent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('wifi','lan','dns','vpn','firewall')]
        [string]$Scenario,

        [int]$MaxSteps = 3
    )

    Write-Host ""
    Write-Host "NetTroubleshooter started" -ForegroundColor Cyan
    Write-Host "Scenario: $Scenario"
    Write-Host "Max steps: $MaxSteps"
    Write-Host ""

    $logPath = Write-AgentLog `
        -Scenario $Scenario `
        -EventType 'RunStarted' `
        -Message "NetTroubleshooter started for scenario '$Scenario'."

    Write-Host "Logging to: $logPath" -ForegroundColor DarkCyan

    $currentData = Get-NetworkInfo -Scenario $Scenario

    Write-AgentLog `
        -Scenario $Scenario `
        -EventType 'InitialDataCollected' `
        -Message 'Initial scenario data collected.' `
        -Output $currentData | Out-Null

    for ($step = 1; $step -le $MaxSteps; $step++) {
        Write-Host ""
        Write-Host "Diagnostic step $step of $MaxSteps" -ForegroundColor Cyan

        $suggestion = Invoke-AgentStep -InputData $currentData

        if (-not $suggestion) {
            Write-Host "No suggestion was generated." -ForegroundColor Yellow

            Write-AgentLog `
                -Scenario $Scenario `
                -EventType 'NoSuggestion' `
                -StepNumber $step `
                -Message 'No suggestion was generated.' | Out-Null

            break
        }

        Write-AgentLog `
            -Scenario $Scenario `
            -EventType 'SuggestionGenerated' `
            -StepNumber $step `
            -Message 'Agent generated a diagnostic suggestion.' `
            -Suggestion $suggestion | Out-Null

        $approved = Test-Approval `
            -Command $suggestion.Command `
            -Reason $suggestion.Reason `
            -Risk $suggestion.Risk

        if (-not $approved) {
            Write-Host "Command not approved. Stopping." -ForegroundColor Yellow

            Write-AgentLog `
                -Scenario $Scenario `
                -EventType 'CommandDeclined' `
                -StepNumber $step `
                -Message 'User declined the suggested command.' `
                -Suggestion $suggestion | Out-Null

            break
        }

        Write-AgentLog `
            -Scenario $Scenario `
            -EventType 'CommandApproved' `
            -StepNumber $step `
            -Message 'User approved the suggested command.' `
            -Suggestion $suggestion | Out-Null

        try {
            $output = Invoke-SafeCommand -CommandKey $suggestion.CommandKey
            Format-AgentOutput -Output $output

            Write-AgentLog `
                -Scenario $Scenario `
                -EventType 'CommandCompleted' `
                -StepNumber $step `
                -Message 'Approved command completed.' `
                -Suggestion $suggestion `
                -Output $output | Out-Null

            $currentData = [pscustomobject]@{
                Type       = $Scenario
                LastStep   = $suggestion
                LastOutput = $output
            }
        }
        catch {
            Write-Host "Command failed: $_" -ForegroundColor Red

            Write-AgentLog `
                -Scenario $Scenario `
                -EventType 'CommandFailed' `
                -StepNumber $step `
                -Message "Command failed: $_" `
                -Suggestion $suggestion | Out-Null

            break
        }

        if ($step -lt $MaxSteps) {
            $continue = Read-Host "Continue to next diagnostic step? (y/n)"

            if ($continue -ne 'y') {
                Write-Host "Diagnostic loop stopped by user." -ForegroundColor Yellow

                Write-AgentLog `
                    -Scenario $Scenario `
                    -EventType 'RunStoppedByUser' `
                    -StepNumber $step `
                    -Message 'User stopped the diagnostic loop.' | Out-Null

                break
            }

            $currentData = Get-NetworkInfo -Scenario $Scenario

            Write-AgentLog `
                -Scenario $Scenario `
                -EventType 'ScenarioDataRefreshed' `
                -StepNumber $step `
                -Message 'Scenario data refreshed before next step.' `
                -Output $currentData | Out-Null
        }
    }

    Write-AgentLog `
        -Scenario $Scenario `
        -EventType 'RunFinished' `
        -Message "NetTroubleshooter finished for scenario '$Scenario'." | Out-Null

    Write-Host ""
    Write-Host "NetTroubleshooter finished." -ForegroundColor Green
    Write-Host "Log file: $logPath" -ForegroundColor DarkCyan
}
