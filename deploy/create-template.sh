#!/bin/bash

# Configuration
TEMPLATE_VMID=9000
TEMPLATE_NAME="ubuntu-2204-docker-template"
STORAGE="local-lvm"
MEMORY=2048
CORES=2

echo "Creating Ubuntu 22.04 template with Docker..."

# Download Ubuntu cloud image
cd /tmp
wget -O jammy-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Install libguestfs-tools if not present
apt-get update
apt-get install -y libguestfs-tools

# Customize the image BEFORE importing
echo "Customizing image with Docker and essentials..."
virt-customize -a jammy-server-cloudimg-amd64.img \
  --install qemu-guest-agent,docker.io,docker-compose,curl,wget,git,htop,vim,net-tools \
  --run-command 'systemctl enable qemu-guest-agent' \
  --run-command 'systemctl enable docker' \
  --run-command 'usermod -aG docker ubuntu' \
  --run-command 'echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu' \
  --run-command 'chmod 440 /etc/sudoers.d/ubuntu' \
  --truncate /etc/machine-id \
  --truncate /var/lib/dbus/machine-id

echo "Creating VM..."
qm create $TEMPLATE_VMID \
  --name $TEMPLATE_NAME \
  --memory $MEMORY \
  --cores $CORES \
  --net0 virtio,bridge=vmbr0

echo "Importing disk..."
qm importdisk $TEMPLATE_VMID jammy-server-cloudimg-amd64.img $STORAGE

echo "Configuring VM..."
qm set $TEMPLATE_VMID --scsihw virtio-scsi-pci
qm set $TEMPLATE_VMID --scsi0 $STORAGE:vm-$TEMPLATE_VMID-disk-0
qm set $TEMPLATE_VMID --boot c --bootdisk scsi0
qm set $TEMPLATE_VMID --ide2 $STORAGE:cloudinit
qm set $TEMPLATE_VMID --serial0 socket --vga serial0
qm set $TEMPLATE_VMID --agent enabled=1

# Resize the disk to 20GB (will grow on clone)
qm resize $TEMPLATE_VMID scsi0 20G

# Set default cloud-init user
qm set $TEMPLATE_VMID --ciuser ubuntu
qm set $TEMPLATE_VMID --cipassword $(openssl rand -base64 12)

echo "Converting to template..."
qm template $TEMPLATE_VMID

echo "Template created successfully!"
echo "Template VMID: $TEMPLATE_VMID"
echo "Template Name: $TEMPLATE_NAME"
echo ""
echo "Verify with: qm list | grep template"

# Cleanup
rm jammy-server-cloudimg-amd64.img