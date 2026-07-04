function Get-AgentKnowledge {
    [CmdletBinding()]
    param(
        [ValidateSet('wifi','lan','dns','vpn','firewall')]
        [string]$Scenario
    )

    $moduleRoot = Split-Path -Parent $PSScriptRoot
    $knowledgeRoot = Join-Path $moduleRoot 'KnowledgeBase'

    if (-not (Test-Path $knowledgeRoot)) {
        Write-Host "KnowledgeBase folder not found." -ForegroundColor Yellow
        return
    }

    $files = if ($Scenario) {
        Get-ChildItem -Path $knowledgeRoot -Filter "$Scenario.json" -ErrorAction SilentlyContinue
    }
    else {
        Get-ChildItem -Path $knowledgeRoot -Filter "*.json" -ErrorAction SilentlyContinue
    }

    if (-not $files) {
        Write-Host "No knowledge base files found." -ForegroundColor Yellow
        return
    }

    foreach ($file in $files) {
        try {
            Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        }
        catch {
            Write-Host "Failed to parse knowledge file: $($file.FullName)" -ForegroundColor Red
            Write-Host $_
        }
    }
}
