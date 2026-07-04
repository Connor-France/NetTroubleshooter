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
