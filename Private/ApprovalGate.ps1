function Test-Approval {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter(Mandatory)]
        [string]$Reason,

        [Parameter(Mandatory)]
        [ValidateSet('low','medium','high')]
        [string]$Risk
    )

    Write-Host ""
    Write-Host "Suggested command:" -ForegroundColor Cyan
    Write-Host "  $Command"

    Write-Host ""
    Write-Host "Reason:" -ForegroundColor Cyan
    Write-Host "  $Reason"

    Write-Host ""
    Write-Host "Risk: $Risk" -ForegroundColor Yellow

    $answer = Read-Host "Approve running this command? (y/n)"
    return $answer -eq 'y'
}
