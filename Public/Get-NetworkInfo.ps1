function Get-NetworkInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('wifi','lan','dns','vpn','firewall')]
        [string]$Scenario
    )

    switch ($Scenario) {
        'wifi' {
            $wifi = netsh wlan show interfaces 2>$null
            $ping = Test-Connection -ComputerName 8.8.8.8 -Count 4 -ErrorAction SilentlyContinue

            [pscustomobject]@{
                Type = 'wifi'
                Wifi = $wifi
                Ping = $ping
            }
        }

        'lan' {
            $ipConfig = Get-NetIPConfiguration -ErrorAction SilentlyContinue
            $routes   = Get-NetRoute -ErrorAction SilentlyContinue

            [pscustomobject]@{
                Type   = 'lan'
                IP     = $ipConfig
                Routes = $routes
            }
        }

        'dns' {
            $dns = Resolve-DnsName 'google.com' -ErrorAction SilentlyContinue
            $servers = Get-DnsClientServerAddress -ErrorAction SilentlyContinue

            [pscustomobject]@{
                Type    = 'dns'
                Dns     = $dns
                Servers = $servers
            }
        }

        'vpn' {
            $vpnConnections = Get-VpnConnection -ErrorAction SilentlyContinue

            $adapters = Get-NetAdapter -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.InterfaceDescription -match 'VPN|TAP|Tunnel|WireGuard|OpenVPN|Cisco|Fortinet|GlobalProtect|AnyConnect'
                }

            $routes = Get-NetRoute -ErrorAction SilentlyContinue

            [pscustomobject]@{
                Type           = 'vpn'
                VpnConnections = $vpnConnections
                Adapters       = $adapters
                Routes         = $routes
            }
        }

        'firewall' {
            $profiles = Get-NetFirewallProfile -ErrorAction SilentlyContinue

            $rules = Get-NetFirewallRule -ErrorAction SilentlyContinue |
                Select-Object -First 100 DisplayName, Direction, Action, Enabled, Profile

            [pscustomobject]@{
                Type     = 'firewall'
                Profiles = $profiles
                Rules    = $rules
            }
        }
    }
}
