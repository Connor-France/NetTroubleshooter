# NetTroubleshooter

NetTroubleshooter is a modular PowerShell-based network diagnostic agent for Windows.

It is designed to collect local network information, suggest safe diagnostic commands, ask for user approval, run approved checks, and write structured logs for later review.

## Current status

Version: `0.1.0`

This is the first safe local-only version.

Current features:

- Wi-Fi diagnostics
- LAN diagnostics
- DNS diagnostics
- VPN diagnostics
- Firewall diagnostics
- User approval gate before command execution
- Safe command allowlist
- Structured JSONL logging
- Modular PowerShell layout

## Safety model

NetTroubleshooter v1 does not automatically change system configuration.

The agent:

1. Collects diagnostic data.
2. Suggests a known-safe diagnostic command.
3. Explains why it wants to run the command.
4. Asks for approval.
5. Runs only approved allowlisted commands.

## Requirements

- Windows
- Windows PowerShell 5.1
- Git, if contributing or tracking changes

## Setup

Import the module:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Import-Module NetTroubleshooter -Force
```

## Usage

Run a one-step Wi-Fi diagnostic:

```powershell
Invoke-Agent -Scenario wifi -MaxSteps 1
```

Available scenarios:

```powershell
Invoke-Agent -Scenario wifi
Invoke-Agent -Scenario dns
Invoke-Agent -Scenario lan
Invoke-Agent -Scenario vpn
Invoke-Agent -Scenario firewall
```

## Logs

Diagnostic runs are logged to:

```text
Logs/
```

Log files use JSON Lines format:

```text
NetTroubleshooter-yyyy-MM-dd.jsonl
```

The `Logs/` folder is ignored by Git so local diagnostic output is not committed.

## Project structure

```text
NetTroubleshooter/
  NetTroubleshooter.psd1
  NetTroubleshooter.psm1
  Public/
    Get-NetworkInfo.ps1
    Invoke-Agent.ps1
    Invoke-AgentStep.ps1
  Private/
    ApprovalGate.ps1
    Format-AgentOutput.ps1
    Invoke-SafeCommand.ps1
    Write-AgentLog.ps1
  Logs/
```

## Planned features

- Human-readable log viewer
- Exportable diagnostic reports
- JSON knowledge base
- Improved rule-based reasoning
- LLM-assisted reasoning
- GUI dashboard
- Remediation and rollback workflows

## Log viewer

You can view the latest diagnostic log in a readable format with:

```powershell
Show-AgentLog
```

Show fewer entries:

```powershell
Show-AgentLog -Tail 5
```

Show more entries:

```powershell
Show-AgentLog -Tail 50
```

This reads the latest `.jsonl` file from the `Logs/` folder and prints a human-friendly summary of recent diagnostic events.

## Report export

You can export the latest diagnostic log to a Markdown report with:

```powershell
Export-AgentReport
```

Export fewer log entries:

```powershell
Export-AgentReport -Tail 10
```

Export more log entries:

```powershell
Export-AgentReport -Tail 100
```

Reports are written to:

```text
Reports/
```

The `Reports/` folder is ignored by Git so generated diagnostic reports are not committed.

## Knowledge base

NetTroubleshooter includes a local JSON knowledge base for known network issue patterns.

Knowledge base files are stored in:

```text
KnowledgeBase/
```

Current scenario knowledge files:

```text
wifi.json
dns.json
lan.json
vpn.json
firewall.json
```

View all knowledge base entries:

```powershell
Get-AgentKnowledge
```

View knowledge for a specific scenario:

```powershell
Get-AgentKnowledge -Scenario wifi
```

Find matching known patterns from collected diagnostic data:

```powershell
$data = Get-NetworkInfo -Scenario wifi
Find-AgentKnowledgeMatch -Scenario wifi -InputData $data
```

During diagnostic runs, `Invoke-Agent` checks for knowledge base matches and displays matching patterns before suggesting the next diagnostic command.

## Testing

NetTroubleshooter uses Pester for PowerShell tests.

Load Pester 5.8.0:

```powershell
Remove-Module Pester -ErrorAction SilentlyContinue
Import-Module Pester -RequiredVersion 5.8.0 -Force
```

Run the current test suite:

```powershell
Invoke-Pester -Path .\Tests\Find-AgentKnowledgeMatch.Tests.ps1 -Output Detailed
```

The current tests validate Wi-Fi knowledge matching:

- strong Wi-Fi signal is not incorrectly flagged as weak
- weak Wi-Fi signal is correctly matched

## Testing

NetTroubleshooter uses Pester for PowerShell tests.

Load Pester 5.8.0:

```powershell
Remove-Module Pester -ErrorAction SilentlyContinue
Import-Module Pester -RequiredVersion 5.8.0 -Force
```

Run the current test suite:

```powershell
Invoke-Pester -Path .\Tests\Find-AgentKnowledgeMatch.Tests.ps1 -Output Detailed
```

The current tests validate Wi-Fi knowledge matching:

- strong Wi-Fi signal is not incorrectly flagged as weak
- weak Wi-Fi signal is correctly matched
