resource "proxmox_vm_qemu" "docker_template" {
  name        = "ubuntu-docker-template"
  target_node = var.node
  vmid        = 9000
  template    = true

  memory  = 2048
  cores   = 2
  sockets = 1
  cpu     = "host"

  scsihw = "virtio-scsi-pci"
  boot   = "order=scsi0"

  disk {
    slot     = 0
    size     = "20G"
    type     = "scsi"
    storage  = var.vm_storage
    file     = "ubuntu-22.04-server-cloudimg-amd64.img"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"

  cicustom = "user=local:snippets/user-data.yaml,meta=local:snippets/meta-data.yaml"

  sshkeys = var.ssh_public_key
}
