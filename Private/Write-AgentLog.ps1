$script:NetTroubleshooterLogRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'Logs'

function Write-AgentLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Scenario,

        [Parameter(Mandatory)]
        [string]$EventType,

        [string]$Message,

        [int]$StepNumber = 0,

        [object]$Suggestion,

        [object]$Output
    )

    if (-not (Test-Path $script:NetTroubleshooterLogRoot)) {
        New-Item -ItemType Directory -Force -Path $script:NetTroubleshooterLogRoot | Out-Null
    }

    $dateStamp = Get-Date -Format 'yyyy-MM-dd'
    $logPath = Join-Path $script:NetTroubleshooterLogRoot "NetTroubleshooter-$dateStamp.jsonl"

    $entry = [pscustomobject]@{
        Timestamp  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Scenario   = $Scenario
        EventType  = $EventType
        StepNumber = $StepNumber
        Message    = $Message
        Suggestion = $Suggestion
        Output     = if ($null -eq $Output) { $null } else { ($Output | Out-String) }
    }

    $entry |
        ConvertTo-Json -Depth 8 -Compress |
        Add-Content -Path $logPath -Encoding UTF8

    return $logPath
}
