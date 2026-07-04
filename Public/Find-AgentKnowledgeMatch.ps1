function Find-AgentKnowledgeMatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('wifi','lan','dns','vpn','firewall')]
        [string]$Scenario,

        [Parameter(Mandatory)]
        [object]$InputData
    )

    $knowledge = Get-AgentKnowledge -Scenario $Scenario

    if (-not $knowledge) {
        return @()
    }

    $knowledgeMatches = New-Object System.Collections.Generic.List[object]

    switch ($Scenario) {
        'wifi' {
            $wifiText = ($InputData.Wifi | Out-String)

            $isDisconnected = $wifiText -notmatch 'State\s*:\s*connected'

            $signal = $null
            $signalMatch = [regex]::Match($wifiText, 'Signal\s*:\s*(\d+)%')

            if ($signalMatch.Success) {
                $signal = [int]$signalMatch.Groups[1].Value
            }

            if ($signal -ne $null -and $signal -lt 40) {
                $pattern = $knowledge.patterns | Where-Object { $_.name -eq 'Weak Wi-Fi signal' }

                if ($pattern) {
                    $knowledgeMatches.Add([pscustomobject]@{
                        Scenario    = $Scenario
                        PatternName = $pattern.name
                        Description = $pattern.description
                        Risk        = $pattern.risk
                        Confidence  = 'medium'
                        Evidence    = "Detected Wi-Fi signal below 40 percent. Signal: $signal%"
                    }) | Out-Null
                }
            }

            if ($isDisconnected) {
                $pattern = $knowledge.patterns | Where-Object { $_.name -eq 'Wi-Fi disconnected' }

                if ($pattern) {
                    $knowledgeMatches.Add([pscustomobject]@{
                        Scenario    = $Scenario
                        PatternName = $pattern.name
                        Description = $pattern.description
                        Risk        = $pattern.risk
                        Confidence  = 'high'
                        Evidence    = 'Wi-Fi state did not appear to be connected.'
                    }) | Out-Null
                }
            }
        }

        'dns' {
            if (-not $InputData.Dns) {
                $pattern = $knowledge.patterns | Where-Object { $_.name -eq 'Default DNS lookup failure' }

                if ($pattern) {
                    $knowledgeMatches.Add([pscustomobject]@{
                        Scenario    = $Scenario
                        PatternName = $pattern.name
                        Description = $pattern.description
                        Risk        = $pattern.risk
                        Confidence  = 'high'
                        Evidence    = 'Default Resolve-DnsName lookup returned no result.'
                    }) | Out-Null
                }
            }
        }

        'lan' {
            $hasIPv4 = $InputData.IP |
                Where-Object { $_.IPv4Address.IPAddress }

            $hasDefaultRoute = $InputData.Routes |
                Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }

            if (-not $hasIPv4) {
                $pattern = $knowledge.patterns | Where-Object { $_.name -eq 'Missing IPv4 address' }

                if ($pattern) {
                    $knowledgeMatches.Add([pscustomobject]@{
                        Scenario    = $Scenario
                        PatternName = $pattern.name
                        Description = $pattern.description
                        Risk        = $pattern.risk
                        Confidence  = 'high'
                        Evidence    = 'No IPv4 address was detected in Get-NetIPConfiguration output.'
                    }) | Out-Null
                }
            }

            if (-not $hasDefaultRoute) {
                $pattern = $knowledge.patterns | Where-Object { $_.name -eq 'Missing default route' }

                if ($pattern) {
                    $knowledgeMatches.Add([pscustomobject]@{
                        Scenario    = $Scenario
                        PatternName = $pattern.name
                        Description = $pattern.description
                        Risk        = $pattern.risk
                        Confidence  = 'high'
                        Evidence    = 'No 0.0.0.0/0 default route was detected.'
                    }) | Out-Null
                }
            }
        }

        'vpn' {
            $connectedVpn = $InputData.VpnConnections |
                Where-Object { $_.ConnectionStatus -eq 'Connected' }

            if (($InputData.VpnConnections -or $InputData.Adapters) -and -not $connectedVpn) {
                $pattern = $knowledge.patterns | Where-Object { $_.name -eq 'VPN disconnected' }

                if ($pattern) {
                    $knowledgeMatches.Add([pscustomobject]@{
                        Scenario    = $Scenario
                        PatternName = $pattern.name
                        Description = $pattern.description
                        Risk        = $pattern.risk
                        Confidence  = 'medium'
                        Evidence    = 'VPN connection or adapter exists, but no active connected VPN was detected.'
                    }) | Out-Null
                }
            }
        }

        'firewall' {
            $blockingOutbound = $InputData.Rules |
                Where-Object {
                    $_.Direction -eq 'Outbound' -and
                    $_.Action -eq 'Block' -and
                    ($_.Enabled -eq $true -or $_.Enabled -eq 'True')
                }

            if ($blockingOutbound) {
                $pattern = $knowledge.patterns | Where-Object { $_.name -eq 'Outbound firewall block' }

                if ($pattern) {
                    $knowledgeMatches.Add([pscustomobject]@{
                        Scenario    = $Scenario
                        PatternName = $pattern.name
                        Description = $pattern.description
                        Risk        = $pattern.risk
                        Confidence  = 'medium'
                        Evidence    = 'One or more enabled outbound block firewall rules were detected.'
                    }) | Out-Null
                }
            }
        }
    }

    return $knowledgeMatches
}
