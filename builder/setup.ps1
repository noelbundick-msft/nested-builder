# Install roles
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Restart-Computer

# Configure networking for nested VMs
New-VMSwitch -Name VmNAT -SwitchType Internal
Get-NetAdapter "vEthernet (VmNAT)" | New-NetIPAddress -IPAddress 192.168.100.1 -AddressFamily IPv4 -PrefixLength 24
New-NetNat -Name LocalNAT -InternalIPInterfaceAddressPrefix 192.168.100.0/24
New-NetFirewallRule -RemoteAddress 192.168.100.0/24 -DisplayName "AllowVmNAT" -Profile Any -Action Allow

# Configure DHCP
Add-DhcpServerV4Scope -Name "VmNAT" -StartRange 192.168.100.2 -EndRange 192.168.100.254 -SubnetMask 255.255.255.0
Set-DhcpServerV4OptionValue -DnsServer 168.63.129.16 -Router 192.168.100.1
Restart-service dhcpserver

# Download Packer
curl.exe -L https://releases.hashicorp.com/packer/1.8.0/packer_1.8.0_windows_amd64.zip -o packer.zip
$shell = New-Object -ComObject Shell.Application
$files = $shell.Namespace((get-item .\packer.zip).FullName).Items()
$shell.NameSpace('C:\Windows\system32\').CopyHere($files)
