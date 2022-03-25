# Configure networking for nested VMs
New-VMSwitch -Name VmNAT -SwitchType Internal
Get-NetAdapter "vEthernet (VmNAT)" | New-NetIPAddress -IPAddress 192.168.100.1 -AddressFamily IPv4 -PrefixLength 24
New-NetNat -Name LocalNAT -InternalIPInterfaceAddressPrefix 192.168.100.0/24
New-NetFirewallRule -RemoteAddress 192.168.100.0/24 -DisplayName "AllowVmNAT" -Profile Any -Action Allow

# Configure DHCP
Add-DhcpServerV4Scope -Name "VmNAT" -StartRange 192.168.100.2 -EndRange 192.168.100.254 -SubnetMask 255.255.255.0
Set-DhcpServerV4OptionValue -DnsServer 168.63.129.16 -Router 192.168.100.1
Restart-service dhcpserver

# Install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install -y packer azcopy10 git
