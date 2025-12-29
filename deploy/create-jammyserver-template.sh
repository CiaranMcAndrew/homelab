# Download Ubuntu cloud image
TEMPLATE_VMID=9001
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Create VM
qm create $TEMPLATE_VMID --name ubuntu-22.04-cloud --memory 2048 --net0 virtio,bridge=vmbr0

# Import disk
qm importdisk $TEMPLATE_VMID jammy-server-cloudimg-amd64.img local-lvm

# Attach disk
qm set $TEMPLATE_VMID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$TEMPLATE_VMID-disk-0

# Add cloud-init drive
qm set $TEMPLATE_VMID --ide2 local-lvm:cloudinit

# Set boot disk
qm set $TEMPLATE_VMID --boot c --bootdisk scsi0

# Add serial console
qm set $TEMPLATE_VMID --serial0 socket --vga serial0

# Convert to template
qm template $TEMPLATE_VMID