terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

# --- Variables avec valeurs par défaut intégrées ---
variable "proxmox_url" {
  type    = string
  default = "https://10.1.102.11:8006/api2/json"
}

variable "proxmox_user" {
  type    = string
  default = "root@pam"
}

variable "proxmox_password" {
  type      = string
  sensitive = true
  default   = "RTel2023"
}

provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "jellyfin" {
  target_node = "rt102p11lin"
  count = 2
  name  = "jellyfin-node-${count.index + 1}"
  clone = "tpl-debian"
  agent = 1

  cpu { cores   = 4 }
  memory  = 4096


  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  scsihw = "virtio-scsi-single"


  disks {
    scsi {
      scsi0 {
        disk {
          size = "20G"
          storage = "local-lvm"
        }
      }
    }
  }
}

resource "proxmox_vm_qemu" "nginx" {
  target_node = "rt102p11lin"
  count = 2
  name  = "nginx-node-${count.index + 1}"
  clone = "tpl-debian"
  agent = 1

  cpu { cores   = 2 }
  memory  = 1024

  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  scsihw = "virtio-scsi-single"


  disks {
    scsi {
      scsi0 {
        disk {
          size = "20G"
          storage = "local-lvm"
        }
      }
    }
  }
}

resource "proxmox_vm_qemu" "ldap" {
  target_node = "rt102p11lin"
  count  = 2
  name   = "ldap-node-${count.index + 1}"
  clone  = "tpl-debian"
  agent  = 1

  cpu { cores  = 2 }
  memory = 1024

  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  scsihw = "virtio-scsi-single"



  disks {
    scsi {
      scsi0 {
        disk {
          size = "20G"
          storage = "local-lvm"
        }
      }
    }
  }
}

resource "proxmox_vm_qemu" "samba" {
  target_node = "rt102p11lin"
  name  = "samba-server"
  clone = "tpl-debian"
  agent = 1

  cpu { cores   = 2 }
  memory  = 2048

  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  scsihw = "virtio-scsi-single"



  disks {
    scsi {
      scsi0 {
        disk {
          size = "20G"
          storage = "local-lvm"
        }
      }
      scsi1 {
        disk {
          size = "50G"
          storage = "local-lvm"
        }
      }
    }
  }
}