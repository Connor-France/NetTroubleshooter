function Invoke-SafeCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CommandKey
    )

    switch ($CommandKey) {
        'ShowWifiInterfaces' {
            netsh wlan show interfaces
        }

        'ShowWifiNetworks' {
            netsh wlan show networks mode=bssid
        }

        'LongPingInternet' {
            Test-Connection 8.8.8.8 -Count 20
        }

        'ResolveGoogle' {
            Resolve-DnsName google.com
        }

        'ShowIPConfig' {
            ipconfig /all
        }

        'ShowRoutes' {
            Get-NetRoute
        }

        'PingInternet' {
            Test-Connection 8.8.8.8 -Count 4
        }

        'ResolveGooglePublicDns' {
            Resolve-DnsName google.com -Server 8.8.8.8
        }

        'ShowDnsServers' {
            Get-DnsClientServerAddress
        }

        'ShowAdapters' {
            Get-NetAdapter
        }

        'ShowVpnConnections' {
            Get-VpnConnection
        }

        'ShowOutboundBlocks' {
            Get-NetFirewallRule |
                Where-Object {
                    $_.Direction -eq 'Outbound' -and
                    $_.Action -eq 'Block' -and
                    ($_.Enabled -eq $true -or $_.Enabled -eq 'True')
                }
        }

        'ShowFirewallProfiles' {
            Get-NetFirewallProfile
        }

        default {
            throw "CommandKey '$CommandKey' is not approved for safe execution."
        }
    }
}
