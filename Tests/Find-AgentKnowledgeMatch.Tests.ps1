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
