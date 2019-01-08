Get-DnsClientServerAddress -InterfaceIndex 14
Set-DnsClientServerAddress -InterfaceIndex 14 -ServerAddresses "8.8.8.8,8.8.4.4"
Get-DnsClientServerAddress -InterfaceIndex 14

# "172.17.145.24,172.17.145.25"