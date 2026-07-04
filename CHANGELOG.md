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

## [0.3.1] - Test suite foundation

### Added

- Added initial Pester test suite.
- Added tests for Wi-Fi knowledge matching.
- Added test coverage for strong Wi-Fi signals not being incorrectly flagged as weak.
- Added test coverage for weak Wi-Fi signals being matched correctly.

### Notes

- Pester 5.8.0 is used for the current test workflow.
- Tests can be run with `Invoke-Pester`.

## [0.3.2] - Expanded matcher test coverage

### Added

- Added LAN matcher tests.
- Added VPN matcher tests.
- Added firewall matcher tests.
- Expanded matcher test coverage across all active diagnostic scenarios.

### Notes

- The matcher test suite now covers Wi-Fi, DNS, LAN, VPN, and firewall scenarios.
- The suite currently contains 11 matcher tests.

## [0.3.3] - Wi-Fi channel diagnostics

### Added

- Added Wi-Fi nearby network/channel collection via `netsh wlan show networks mode=bssid`.
- Added `WifiNetworks` data to the Wi-Fi collector.
- Added `Wi-Fi channel congestion` pattern to the Wi-Fi knowledge base.
- Added matcher logic for crowded Wi-Fi channels.
- Added Pester tests for Wi-Fi channel diagnostics.

### Notes

- Channel congestion detection currently flags possible congestion when three or more nearby BSSIDs are detected on the same channel.
- Checks remain read-only and non-destructive.

## [0.3.4] - MTU/MSS diagnostics

### Added

- Added safe MTU diagnostic command keys:
  - `PingMtu1472Google`
  - `PingMtu1400Google`
- Added `Suspected MTU/MSS path issue` to the LAN knowledge base.
- Added matcher logic for suspected MTU/MSS path issues.
- Added Pester tests for suspected and healthy MTU/MSS paths.

### Notes

- MTU/MSS detection currently uses the pattern: large DF ping fails while smaller DF ping succeeds.
- Checks remain read-only and non-destructive.
- The matcher test suite now contains 15 tests.
