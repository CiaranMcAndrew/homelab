resource "proxmox_vm_qemu" "vm" {
  name        = "vm-01"
  target_node = var.proxmox_node
  
  # Clone from template
  clone      = var.template_name
  full_clone = true
  
  # VM configuration
  cores   = 4
  sockets = 1
  memory  = 8192  # MB
  
  # Boot configuration
  agent   = 1  # Enable QEMU guest agent
  
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"  # Explicitly set boot disk
  cicustom = "user=local:snippets/base.yaml"
  # OS disk
  disk {
    slot    = "scsi0"
    storage = "local-lvm"
    size    = "60G"
    type    = "disk"
  }

  # Cloud-init drive (REQUIRED)
  disk {
    slot     = "ide2"
    type     = "cloudinit"
    storage  = "local-lvm"
  }

  # Network configuration
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Cloud-init configuration
  ipconfig0 = "ip=dhcp"
  sshkeys   = var.ssh_public_key
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}