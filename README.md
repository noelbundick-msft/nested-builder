# nested-builder

## Usage

### Resource deployment

In a Codespace, deploy the Bicep template to stand up a builder VM with nested virtualization enabled

```shell
# Login for codespaces
az login --use-device-code

# Deploy the builder VM
az deployment sub create -l westus3 -f ./builder/main.bicep
```

### Builder VM configuration

On the builder VM, enable the Hyper-V role and configure networking to build nested VMs

```powershell
.\setup.ps1
```

### Build a VHD image via Packer

Use Packer to automate installing Linux from an ISO, configuring it for Azure, and exporting it to a VHD

```powershell
cd centos63
packer build centos63.pkr.hcl
azcopy copy '.\output-centos63\Virtual Hard Disks\packer-centos63.vhd' https://builder34n3pk.blob.core.windows.net/images/centos63.vhd
```

In your codespace, create an image from the exported VHD

```shell
az image create -g builder -n centos63 --os-type Linux --source https://builder34n3pk.blob.core.windows.net/images/centos63.vhd
```

Now create a VM from the image

```shell
ADMIN_USER=azureuser
ADMIN_PASS=Password#1234
RESOURCE_GROUP=josh-test-3
VM_NAME=test1
IMAGE_ID=$(az image show -g builder-josh -n centos63-2 --query id -o tsv)
az group create -n $RESOURCE_GROUP -l westus3
az vm create -n $VM_NAME -g $RESOURCE_GROUP --image $IMAGE_ID
az vm user update -u $ADMIN_USER -p $ADMIN_PASS -g $RESOURCE_GROUP -n $VM_NAME`
```

## Overview

* `/builder` - stands up a builder VM with
  * Nested virtualization
  * Just-in-time RDP access
  * Auto-shutdown
  * `setup.ps1` - PowerShell setup steps
    * Install Hyper-V and DHCP
    * Configure a network / NAT
    * Setup DHCP
    * Install Packer
    * Install azcopy
* `/centos63` - configuration to create a CentOS 6.3 image via Packer
  * `centos63.pkr.hcl` - the Packer configuration with
    * Pull/cache an ISO
    * Export to legacy VHD format for Azure
    * Serve a directory via HTTP
    * Automate pressing the OK button for unsupported hardware
    * `ks.cfg` - RHEL/CentOS OS installation
      * Set input/locale
      * Use cdrom (ISO) sources
      * Install Linux Integration Services (needed for Packer SSH)
    * `postinstall.sh` - install script run by Packer
      * Customize kernel params
      * Update repos to point to archive.org for CentOS 6.3
      * Add OpenLogic repo
      * Configure networking
      * Deprovision to prepare for Azure
