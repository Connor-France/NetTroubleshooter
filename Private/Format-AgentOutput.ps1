function Format-AgentOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Output
    )

    Write-Host ""
    Write-Host "Command output:" -ForegroundColor Green
    Write-Host "----------------------------------------"

    if ($null -eq $Output) {
        Write-Host "No output returned."
    }
    else {
        $Output | Out-String | Write-Host
    }

    Write-Host "----------------------------------------"
}
