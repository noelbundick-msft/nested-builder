source "azure-arm" "custom-centos63" {
  # Connection details
  use_azure_cli_auth = true

  # Build options
  os_type                    = "Linux"
  location                   = "westus3"
  vm_size                    = "Standard_DS2_v2"
  async_resourcegroup_delete = true
  ssh_pty                    = true     # CentOS requires a tty for sudo

  # Source image
  custom_managed_image_resource_group_name = "images"
  custom_managed_image_name                 = "centos63"

  # Output
  managed_image_resource_group_name = "images"
  managed_image_name                = "custom-centos63"
}

build {
  sources = ["sources.azure-arm.custom-centos63"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    script = "customize.sh"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["yum update -y", "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
    skip_clean      = true
  }
}
