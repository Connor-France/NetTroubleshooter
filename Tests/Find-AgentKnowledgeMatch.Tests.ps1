BeforeAll {
    Import-Module "$PSScriptRoot\..\NetTroubleshooter.psd1" -Force
}

Describe "Find-AgentKnowledgeMatch - Wi-Fi" {
    It "does not flag strong Wi-Fi signal as weak" {
        $fakeWifiData = [pscustomobject]@{
            Type = "wifi"
            Wifi = @"
State                  : connected
SSID                   : TestNetwork
Signal                 : 87%
"@
            Ping = @()
        }

        $result = Find-AgentKnowledgeMatch -Scenario wifi -InputData $fakeWifiData

        $result.PatternName | Should -Not -Contain "Weak Wi-Fi signal"
    }

    It "flags weak Wi-Fi signal" {
        $fakeWifiData = [pscustomobject]@{
            Type = "wifi"
            Wifi = @"
State                  : connected
SSID                   : TestNetwork
Signal                 : 25%
"@
            Ping = @()
        }

        $result = Find-AgentKnowledgeMatch -Scenario wifi -InputData $fakeWifiData

        $result.PatternName | Should -Contain "Weak Wi-Fi signal"
    }
}

Describe "Find-AgentKnowledgeMatch - DNS" {
    It "does not flag DNS as failed when DNS data exists" {
        $fakeDnsData = [pscustomobject]@{
            Type = "dns"
            Dns = @(
                [pscustomobject]@{
                    Name      = "google.com"
                    Type      = "A"
                    IPAddress = "142.250.140.100"
                }
            )
            Servers = @()
        }

        $result = Find-AgentKnowledgeMatch -Scenario dns -InputData $fakeDnsData

        $result.PatternName | Should -Not -Contain "Default DNS lookup failure"
    }

    It "flags DNS lookup failure when DNS data is missing" {
        $fakeDnsData = [pscustomobject]@{
            Type    = "dns"
            Dns     = $null
            Servers = @()
        }

        $result = Find-AgentKnowledgeMatch -Scenario dns -InputData $fakeDnsData

        $result.PatternName | Should -Contain "Default DNS lookup failure"
    }
}

Describe "Find-AgentKnowledgeMatch - LAN" {
    It "does not flag healthy LAN data" {
        $fakeLanData = [pscustomobject]@{
            Type = "lan"
            IP = @(
                [pscustomobject]@{
                    IPv4Address = [pscustomobject]@{
                        IPAddress = "192.168.1.100"
                    }
                }
            )
            Routes = @(
                [pscustomobject]@{
                    DestinationPrefix = "0.0.0.0/0"
                }
            )
        }

        $result = Find-AgentKnowledgeMatch -Scenario lan -InputData $fakeLanData

        $result.PatternName | Should -Not -Contain "Missing IPv4 address"
        $result.PatternName | Should -Not -Contain "Missing default route"
    }

    It "flags missing IPv4 address" {
        $fakeLanData = [pscustomobject]@{
            Type = "lan"
            IP = @(
                [pscustomobject]@{
                    IPv4Address = $null
                }
            )
            Routes = @(
                [pscustomobject]@{
                    DestinationPrefix = "0.0.0.0/0"
                }
            )
        }

        $result = Find-AgentKnowledgeMatch -Scenario lan -InputData $fakeLanData

        $result.PatternName | Should -Contain "Missing IPv4 address"
    }

    It "flags missing default route" {
        $fakeLanData = [pscustomobject]@{
            Type = "lan"
            IP = @(
                [pscustomobject]@{
                    IPv4Address = [pscustomobject]@{
                        IPAddress = "192.168.1.100"
                    }
                }
            )
            Routes = @()
        }

        $result = Find-AgentKnowledgeMatch -Scenario lan -InputData $fakeLanData

        $result.PatternName | Should -Contain "Missing default route"
    }
}

Describe "Find-AgentKnowledgeMatch - VPN" {
    It "does not flag VPN disconnected when VPN is connected" {
        $fakeVpnData = [pscustomobject]@{
            Type = "vpn"
            VpnConnections = @(
                [pscustomobject]@{
                    ConnectionStatus = "Connected"
                }
            )
            Adapters = @(
                [pscustomobject]@{
                    InterfaceDescription = "Test VPN Adapter"
                }
            )
            Routes = @()
        }

        $result = Find-AgentKnowledgeMatch -Scenario vpn -InputData $fakeVpnData

        $result.PatternName | Should -Not -Contain "VPN disconnected"
    }

    It "flags VPN disconnected when VPN exists but is not connected" {
        $fakeVpnData = [pscustomobject]@{
            Type = "vpn"
            VpnConnections = @(
                [pscustomobject]@{
                    ConnectionStatus = "Disconnected"
                }
            )
            Adapters = @(
                [pscustomobject]@{
                    InterfaceDescription = "Test VPN Adapter"
                }
            )
            Routes = @()
        }

        $result = Find-AgentKnowledgeMatch -Scenario vpn -InputData $fakeVpnData

        $result.PatternName | Should -Contain "VPN disconnected"
    }
}

Describe "Find-AgentKnowledgeMatch - Firewall" {
    It "does not flag outbound firewall block when no outbound block rules exist" {
        $fakeFirewallData = [pscustomobject]@{
            Type = "firewall"
            Profiles = @()
            Rules = @(
                [pscustomobject]@{
                    Direction = "Outbound"
                    Action    = "Allow"
                    Enabled   = $true
                }
            )
        }

        $result = Find-AgentKnowledgeMatch -Scenario firewall -InputData $fakeFirewallData

        $result.PatternName | Should -Not -Contain "Outbound firewall block"
    }

    It "flags outbound firewall block when enabled outbound block rule exists" {
        $fakeFirewallData = [pscustomobject]@{
            Type = "firewall"
            Profiles = @()
            Rules = @(
                [pscustomobject]@{
                    Direction = "Outbound"
                    Action    = "Block"
                    Enabled   = $true
                }
            )
        }

        $result = Find-AgentKnowledgeMatch -Scenario firewall -InputData $fakeFirewallData

        $result.PatternName | Should -Contain "Outbound firewall block"
    }
}
