# Changelog

All notable changes to NetTroubleshooter will be documented in this file.

The format is based on simple version sections so progress is easy to track.

## [0.1.0] - Initial local diagnostic module

### Added

- Created modular PowerShell module structure.
- Added Wi-Fi diagnostic scenario.
- Added LAN diagnostic scenario.
- Added DNS diagnostic scenario.
- Added VPN diagnostic scenario.
- Added firewall diagnostic scenario.
- Added user approval gate before command execution.
- Added safe command allowlist.
- Added structured JSONL logging.
- Added `.gitignore` to exclude generated logs.
- Added Git repository tracking.
- Added GitHub remote repository.

### Safety

- No automatic configuration changes.
- No auto-fix mode.
- No arbitrary command execution.
- Commands must be approved by the user.
- Only allowlisted diagnostic commands can run.

## Planned

### 0.2.0

- Add `Show-AgentLog` command for readable log summaries.
- Add `Export-AgentReport` command.
- Improve log formatting.

### 0.3.0

- Add JSON knowledge base.
- Add richer local reasoning rules.
- Add clearer issue categories.

### 0.4.0

- Add optional LLM-assisted reasoning.
- Keep approval gate and safe execution model.

### 0.5.0

- Add GUI dashboard prototype.

### Future

- Remediation workflows.
- Rollback workflows.
- Background monitoring.
- System tray mode.

## [0.2.0] - Log viewer

### Added

- Added `Show-AgentLog` command.
- Added readable summaries for recent JSONL diagnostic log events.
- Added support for `-Tail` to control how many log entries are displayed.

### Notes

- This is the first v0.2.0 feature.
- Log files remain local and are still excluded from Git.

## [0.2.1] - Report export

### Added

- Added `Export-AgentReport` command.
- Added Markdown report generation from the latest diagnostic log.
- Added `Reports/` output folder for generated reports.
- Added support for `-Tail` to control how many log entries are included in a report.

### Changed

- Updated `.gitignore` to exclude generated reports.

### Notes

- Generated reports remain local and are not committed to Git.

## [0.3.0] - Knowledge base and pattern matching

### Added

- Added `KnowledgeBase/` folder.
- Added JSON knowledge files for Wi-Fi, DNS, LAN, VPN, and firewall scenarios.
- Added `Get-AgentKnowledge` command.
- Added `Find-AgentKnowledgeMatch` command.
- Added knowledge base matching into `Invoke-Agent`.
- Added logging for knowledge match and no-match events.

### Fixed

- Fixed Wi-Fi signal parsing bug caused by PowerShell regex match variable behaviour.

### Notes

- Knowledge matching is currently local and rule-based.
- No LLM is required for this milestone.
- The agent remains read-only and approval-based.
