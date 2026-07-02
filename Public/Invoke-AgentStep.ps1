function Invoke-AgentStep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$InputData
    )

    switch ($InputData.Type) {
        'wifi' {
            $wifiText = ($InputData.Wifi | Out-String)
            $avgPing = $null

            if ($InputData.Ping) {
                $avgPing = ($InputData.Ping | Measure-Object -Property ResponseTime -Average).Average
            }

            $isDisconnected = $wifiText -notmatch 'State\s*:\s*connected'

            $signal = $null
            if ($wifiText -match 'Signal\s*:\s*(\d+)%') {
                $signal = [int]$matches[1]
            }

            if ($isDisconnected) {
                return [pscustomobject]@{
                    CommandKey = 'ShowWifiInterfaces'
                    Command    = 'netsh wlan show interfaces'
                    Reason     = 'Wi-Fi does not appear to be connected. Confirm adapter state and connected SSID.'
                    Risk       = 'low'
                }
            }

            if ($signal -ne $null -and $signal -lt 40) {
                return [pscustomobject]@{
                    CommandKey = 'ShowWifiNetworks'
                    Command    = 'netsh wlan show networks mode=bssid'
                    Reason     = "Wi-Fi signal appears weak at $signal%. Check nearby networks and possible channel congestion."
                    Risk       = 'low'
                }
            }

            if ($avgPing -ne $null -and $avgPing -gt 100) {
                $roundedPing = [math]::Round($avgPing, 2)

                return [pscustomobject]@{
                    CommandKey = 'LongPingInternet'
                    Command    = 'Test-Connection 8.8.8.8 -Count 20'
                    Reason     = "Average ping is high at $roundedPing ms. Run a longer stability test."
                    Risk       = 'low'
                }
            }

            return [pscustomobject]@{
                CommandKey = 'ResolveGoogle'
                Command    = 'Resolve-DnsName google.com'
                Reason     = 'Wi-Fi looks connected. Check DNS resolution next.'
                Risk       = 'low'
            }
        }

        'lan' {
            $hasDefaultRoute = $InputData.Routes |
                Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }

            $hasIPv4 = $InputData.IP |
                Where-Object { $_.IPv4Address.IPAddress }

            if (-not $hasIPv4) {
                return [pscustomobject]@{
                    CommandKey = 'ShowIPConfig'
                    Command    = 'ipconfig /all'
                    Reason     = 'No IPv4 address was detected. Inspect adapter and DHCP configuration.'
                    Risk       = 'low'
                }
            }

            if (-not $hasDefaultRoute) {
                return [pscustomobject]@{
                    CommandKey = 'ShowRoutes'
                    Command    = 'Get-NetRoute'
                    Reason     = 'No default route was detected. Inspect the routing table.'
                    Risk       = 'low'
                }
            }

            return [pscustomobject]@{
                CommandKey = 'PingInternet'
                Command    = 'Test-Connection 8.8.8.8 -Count 4'
                Reason     = 'LAN configuration has IPv4 and a default route. Test external connectivity.'
                Risk       = 'low'
            }
        }

        'dns' {
            if (-not $InputData.Dns) {
                return [pscustomobject]@{
                    CommandKey = 'ResolveGooglePublicDns'
                    Command    = 'Resolve-DnsName google.com -Server 8.8.8.8'
                    Reason     = 'Default DNS lookup failed. Test resolution against a public DNS server.'
                    Risk       = 'low'
                }
            }

            return [pscustomobject]@{
                CommandKey = 'ShowDnsServers'
                Command    = 'Get-DnsClientServerAddress'
                Reason     = 'DNS resolved. Show configured DNS servers for confirmation.'
                Risk       = 'low'
            }
        }

        'vpn' {
            $connectedVpn = $InputData.VpnConnections |
                Where-Object { $_.ConnectionStatus -eq 'Connected' }

            if (-not $InputData.VpnConnections -and -not $InputData.Adapters) {
                return [pscustomobject]@{
                    CommandKey = 'ShowAdapters'
                    Command    = 'Get-NetAdapter'
                    Reason     = 'No obvious VPN connection or VPN adapter was detected.'
                    Risk       = 'low'
                }
            }

            if (-not $connectedVpn) {
                return [pscustomobject]@{
                    CommandKey = 'ShowVpnConnections'
                    Command    = 'Get-VpnConnection'
                    Reason     = 'A VPN connection or adapter exists, but no VPN appears connected.'
                    Risk       = 'low'
                }
            }

            return [pscustomobject]@{
                CommandKey = 'ShowRoutes'
                Command    = 'Get-NetRoute'
                Reason     = 'VPN appears connected. Inspect routing to check split tunnel or full tunnel behaviour.'
                Risk       = 'low'
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
                return [pscustomobject]@{
                    CommandKey = 'ShowOutboundBlocks'
                    Command    = 'Get-NetFirewallRule | Where-Object { $_.Direction -eq "Outbound" -and $_.Action -eq "Block" -and $_.Enabled -eq $true }'
                    Reason     = 'One or more enabled outbound blocking firewall rules were detected.'
                    Risk       = 'low'
                }
            }

            return [pscustomobject]@{
                CommandKey = 'ShowFirewallProfiles'
                Command    = 'Get-NetFirewallProfile'
                Reason     = 'No obvious outbound block found in sampled rules. Inspect firewall profiles.'
                Risk       = 'low'
            }
        }
    }
}
