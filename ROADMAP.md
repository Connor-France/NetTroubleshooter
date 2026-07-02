# Roadmap

This roadmap tracks planned development for NetTroubleshooter.

## Current version

### v0.1.0 - Safe local diagnostic foundation

Status: Complete

Implemented:

- Modular PowerShell module structure
- Wi-Fi diagnostics
- LAN diagnostics
- DNS diagnostics
- VPN diagnostics
- Firewall diagnostics
- Approval gate
- Safe command allowlist
- Structured JSONL logging
- Git and GitHub setup

## Next milestones

### v0.2.0 - Log viewer and reports

Goal: Make diagnostic output easier to review.

Planned:

- Add `Show-AgentLog`
- Add readable summaries of recent diagnostic runs
- Add `Export-AgentReport`
- Export reports as `.txt` or `.md`
- Improve log event formatting

### v0.3.0 - Knowledge base

Goal: Add known issue patterns without requiring an LLM.

Planned:

- Add `KnowledgeBase/` folder
- Add JSON pattern files for:
  - Wi-Fi
  - LAN
  - DNS
  - VPN
  - Firewall
- Match diagnostic data against known issue patterns
- Suggest likely causes based on local rules

### v0.4.0 - Smarter reasoning

Goal: Improve local diagnostic decision-making.

Planned:

- Add confidence levels
- Add issue categories
- Add clearer next-step suggestions
- Add better parsing for Wi-Fi signal, DNS failures, routes, and firewall rules

### v0.5.0 - Optional LLM brain

Goal: Add AI-assisted reasoning while preserving safety.

Planned:

- Add optional Python LLM bridge
- Send structured diagnostic data to the LLM
- Require structured JSON responses
- Keep command approval gate
- Keep safe command allowlist
- Prevent arbitrary command execution

### v0.6.0 - GUI dashboard

Goal: Add a simple visual interface.

Planned:

- Add PowerShell WPF dashboard
- Add buttons for each scenario
- Show diagnostic output in a scrollable panel
- Show log file location
- Add run status indicators

## Future ideas

- Remediation workflows
- Rollback workflows
- Background monitoring
- System tray mode
- Network health score
- Scheduled diagnostics
- GitHub issue templates
- Pester test suite
- Module installer script
