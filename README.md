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
```
