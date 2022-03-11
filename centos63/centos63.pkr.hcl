source "hyperv-iso" "centos63" {
    iso_url = "https://archive.org/download/centos-6.3_release/CentOS-6.3-x86_64-minimal.iso"
    iso_checksum = "b8a2950f87858f846d1381edef3f0e3d6624631659eb6de8bc8e9da09f1b19ad"
    disk_size = 10240
    use_legacy_network_adapter = true
    use_fixed_vhd_format = true
    skip_compaction = true
    differencing_disk = false
    memory = 2048
    switch_name = "VmNAT"
    generation = 1

    ssh_username = "root"
    ssh_password = "to_be_disabled"
    ssh_timeout = "8h"

    http_directory = "."

    boot_command = [
        "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>",  # start the install
        "<wait60s><enter><wait>" # press OK for unsupported hardware
    ]

    shutdown_command = "shutdown -P now"
}

build {
  sources = ["sources.hyperv-iso.centos63"]

  provisioner "shell" {
    script = "postinstall.sh"
  }
}
