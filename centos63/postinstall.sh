#!/bin/bash
set -ex

# Remove unneeded parameters in grub
sed -i 's/ rhgb//g' /boot/grub/grub.conf
sed -i 's/ quiet//g' /boot/grub/grub.conf
sed -i 's/ crashkernel=auto//g' /boot/grub/grub.conf

cat <<EOF > /etc/yum.repos.d/CentOS-Base.repo
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-6.3 - Base
baseurl=http://linuxsoft.cern.ch/centos-vault/6.3/os/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
 
#released updates
[updates]
name=CentOS-6.3 - Updates
baseurl=http://linuxsoft.cern.ch/centos-vault/6.3/updates/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
 
#additional packages that may be useful
[extras]
name=CentOS-6.3 - Extras
baseurl=http://linuxsoft.cern.ch/centos-vault/6.3/extras/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
 
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-6.3 - Plus
baseurl=http://linuxsoft.cern.ch/centos-vault/6.3/centosplus/x86_64/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

EOF

cat <<EOF > /etc/yum.repos.d/OpenLogic.repo
[openlogic]
name=CentOS-6 - OpenLogic packages for x86_64
baseurl=http://olcentgbl.trafficmanager.net/openlogic/6/openlogic/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://olcentgbl.trafficmanager.net/openlogic/6/openlogic/x86_64/OpenLogic-GPG-KEY
EOF


# Modify yum
echo "http_caching=packages" >> /etc/yum.conf
yum clean all

# Fix root certs
yum reinstall -y ca-certificates

# Install packages (from OpenLogic base)
yum install -y \
    @base \
    @console-internet \
    @core \
    @debugging \
    @directory-client \
    @hardware-monitoring \
    @java-platform \
    @large-systems \
    @network-file-system-client \
    @performance \
    @perl-runtime \
    @server-platform \
    ntp \
    dnsmasq \
    cifs-utils \
    sudo \
    python-pyasn1 \
    parted \
    WALinuxAgent \
    -dracut-config-rescue

# services --enabled="sshd,waagent,ntpd,dnsmasq,hypervkvpd"

# Configure ssh
sed -i 's/^#\(ClientAliveInterval\).*$/\1 180/g' /etc/ssh/sshd_config

# Configure network
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
PERSISTENT_DHCLIENT=yes
EOF

cat <<EOF > /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

# Disable persistent net rules
touch /etc/udev/rules.d/75-persistent-net-generator.rules
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules /etc/udev/rules.d/70-persistent-net.rules

# Deprovision and prepare for Azure
/usr/sbin/waagent -force -deprovision
