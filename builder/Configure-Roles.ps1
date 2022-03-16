# Install roles
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Restart-Computer -Force
