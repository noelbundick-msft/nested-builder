# nested-builder

## Usage

### Resource deployment

In a Codespace, deploy the builder VM with nested virtualization enabled. Examples are provided for Bicep and Terraform.

```shell
# Login for codespaces
az login --use-device-code

# [Option 1] Deploy the builder VM (Bicep)
az deployment sub create -l westus3 -f ./iac/bicep/main.bicep

# [Option 2] Deploy the builder VM (Terraform)
pushd iac/terraform
terraform init
terraform apply
popd
```

### Builder VM configuration

Run configuration scripts to enable the Hyper-V role and configure networking to build nested VMs

```powershell
az vm run-command invoke --command-id RunPowerShellScript -g builder -n builder --scripts @builder/Configure-Roles.ps1
az vm run-command invoke --command-id RunPowerShellScript -g builder -n builder --scripts @builder/Configure-VM.ps1
```

### Build a VHD image via Packer

RDP to the builder VM and open PowerShell as Administrator. Clone this repo, then use Packer to automate installing Linux from an ISO, configuring it for Azure, and exporting it to a VHD

```powershell
# Clone the repo
git clone https://github.com/noelbundick-msft/nested-builder

# Build a CentOS 6.3 image
cd nested-builder/centos63
packer build centos63.pkr.hcl
azcopy copy '.\output-centos63\Virtual Hard Disks\packer-centos63.vhd' https://builder34n3pk.blob.core.windows.net/images/centos63.vhd
```

### Create the image in Azure

In your codespace, create an image from the exported VHD

```shell
az image create -g images -n centos63 --os-type Linux --source https://builder34n3pk.blob.core.windows.net/images/centos63.vhd
```

### Validate the image

In your codespace, create a VM from the image

```shell
IMAGE_ID=$(az image show -g images -n centos63 --query id -o tsv)
az group create -n test1 -l westus3
az vm create -n test1 -g test1 --image $IMAGE_ID
```

### Customize a child image

In your codespace, use Packer to further customize the image. This will create a new VM in Azure, run a customization script, then capture the disk entirely in Azure without the need to use the Hyper-V nested builder

```shell
cd centos63-custom/
packer build ./centos63-custom.pkr.hcl
```

## Overview

* `/builder` - stands up a builder VM with
  * Nested virtualization
  * Just-in-time RDP access
  * Auto-shutdown
  * `Configure-Roles.ps1`
    * Install Hyper-V and DHCP
  * `Configure-VM.ps1`
    * Configure a network / NAT
    * Setup DHCP
    * Install chocolatey + latest versions of:
      * Packer
      * azcopy
      * git
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
* `/centos63-custom` - sample to create a further customized image using the Azure ARM builder from the CentOS 6.3 base
