variable "proxmox_url" {
  default = "https://10.1.102.11:8006/api2/json"
}

variable "proxmox_user" {
  default = "root@pam"
}

variable "proxmox_password" {
  default = "RTel2023"
}


packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "debian-template" {
  proxmox_url   = var.proxmox_url
  username      = var.proxmox_user
  password      = var.proxmox_password
  insecure_skip_tls_verify  = true

  node     = "rt102p11lin"
  iso_file = "local:iso/debian-12.0.0-amd64-netinst.iso"

  memory = 2048
  cores  = 2

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
    mac_address = "BC:24:11:17:01:35" # MAC de base
  }

  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  ssh_username = "streaming-admin"
  ssh_password = "password"
  ssh_timeout  = "60m"

  template_name        = "tpl-debian"
  template_description = "Debian 12 Cloud-Init ready"
  unmount_iso          = true
}

build {
  # --- Template debian ---
  source "source.proxmox-iso.debian-template" {
    name = "debian"
    vm_name = "tpl-debian"
    boot_command = ["<esc><wait>auto preseed/url=http://10.1.102.41/preseed.cfg<enter>"]
  }
    provisioner "shell" {
      inline = [
        "echo 'Kickstart file URL set in boot options.'"
      ]
    }
}