$dnsConfigurations = @{
    "ms_tcpip"  = "1.1.1.3", "1.0.0.3"
    "ms_tcpip6" = "2606:4700:4700::1113", "2606:4700:4700::1003"
}

function Set-Dns {
    Write-Host "Setting DNS..."

    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
        foreach ($componentID in $dnsConfigurations.Keys) {
            if ((Get-NetAdapterBinding -InterfaceAlias $_.Name -ComponentID $componentID).Enabled) {
                Set-DnsClientServerAddress -InterfaceAlias $_.Name -ServerAddresses $dnsConfigurations[$componentID]
            }
        }
    }
}

$null = Register-ObjectEvent -InputObject ([System.Net.NetworkInformation.NetworkChange]) -EventName "NetworkAddressChanged" -Action {
    Set-Dns
}
Set-Dns

Wait-Event
