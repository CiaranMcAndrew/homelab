#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Configuration
# ----------------------------
VMID=108
VM_NAME="docker-vm"
VM_USER="ciaran"
STORAGE="local-lvm"
TEMPLATE_DIR="/var/lib/vz/template/iso"
SNIPPETS_DIR="/var/lib/vz/snippets"
IMAGE="debian-12-genericcloud-amd64.qcow2"
URL="https://cdimage.debian.org/images/cloud/bookworm/latest/${IMAGE}"
MEMORY=8192
CORES=4
BRIDGE="vmbr0"
SSH_KEY="$HOME/.ssh/ciaran.pub"

# ----------------------------
# Prepare directories
# ----------------------------
mkdir -p "$TEMPLATE_DIR" "$SNIPPETS_DIR"
cd "$TEMPLATE_DIR"

# ----------------------------
# Download image if missing
# ----------------------------
if [ ! -f "$IMAGE" ]; then
    echo "Downloading Debian cloud image..."
    curl -LO "$URL"
else
    echo "Image already exists"
fi

# ----------------------------
# Remove existing VM if it exists
# ----------------------------
if qm status "$VMID" &>/dev/null; then
    echo "Stopping and destroying existing VM $VMID..."
    qm stop "$VMID" || true
    qm destroy "$VMID" --purge
fi

# ----------------------------
# Create the VM
# ----------------------------
echo "Creating new VM..."
qm create "$VMID" \
  --name "$VM_NAME" \
  --memory "$MEMORY" \
  --cores "$CORES" \
  --net0 virtio,bridge="$BRIDGE" \
  --scsihw virtio-scsi-pci \
  --boot order=scsi0 \
  --serial0 socket \
  --vga serial0 \
  --agent enabled=1 \
  --ide2 "$STORAGE":cloudinit

# ----------------------------
# Import disk
# ----------------------------
echo "Importing disk..."
qm importdisk "$VMID" "$IMAGE" "$STORAGE"

# Attach imported disk
qm set "$VMID" \
  --scsi0 "$STORAGE:vm-$VMID-disk-0"

# ----------------------------
# Cloud-init custom snippet
# ----------------------------
echo "Creating cloud-init user-data snippet..."

# Read the SSH key content
SSH_KEY_CONTENT=$(cat "$SSH_KEY")

# Hash password
PASSWORD_HASH=$(openssl passwd -6 "password123")

# Create the cloud-init config with proper variable substitution
cat > "$SNIPPETS_DIR/base.yaml" <<EOF
#cloud-config
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - sudo
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
users:
  - name: ${VM_USER}
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    ssh_authorized_keys:
      - ${SSH_KEY_CONTENT}
EOF

# ----------------------------
# Apply cloud-init config
# ----------------------------
qm set "$VMID" --cicustom "user=local:snippets/base.yaml"
qm set "$VMID" --ipconfig0 ip=dhcp

# ----------------------------
# Start VM
# ----------------------------
echo "Starting VM..."
qm start "$VMID"

# ----------------------------
# Wait for QEMU Guest Agent
# ----------------------------
echo "Waiting for QEMU Guest Agent to become available..."
AGENT_OK=0
for i in {1..60}; do
    if qm agent "$VMID" ping &>/dev/null; then
        echo "QEMU Guest Agent is running"
        AGENT_OK=1
        break
    fi
    echo "  Attempt $i/60: agent not ready yet..."
    sleep 5
done

if [ "$AGENT_OK" -ne 1 ]; then
    echo "WARNING: QEMU Guest Agent never came up (this is normal on first boot)"
    echo "The VM should still be accessible via SSH once cloud-init completes"
fi

# ----------------------------
# Get IP address
# ----------------------------
echo ""
echo "Waiting for IP address..."
sleep 20  # Give cloud-init time to configure network

IP_ADDR=""
for i in {1..30}; do
    if [ "$AGENT_OK" -eq 1 ]; then
        IP_ADDR=$(qm guest cmd "$VMID" network-get-interfaces 2>/dev/null | \
                  jq -r '.[] | select(.name=="eth0" or .name=="ens18") | .["ip-addresses"][] | select(.["ip-address-type"]=="ipv4") | .["ip-address"]' 2>/dev/null | \
                  grep -v "127.0.0.1" | head -n1) || true
    fi
    
    if [ -n "$IP_ADDR" ]; then
        break
    fi
    
    echo "  Attempt $i/30: waiting for IP..."
    sleep 5
done

if [ -n "$IP_ADDR" ]; then
    echo ""
    echo "=========================================="
    echo "VM created successfully!"
    echo "=========================================="
    echo "VM ID: $VMID"
    echo "VM Name: $VM_NAME"
    echo "IP Address: $IP_ADDR"
    echo "User: $VM_USER"
    echo ""
    echo "Connect with:"
    echo "  ssh $VM_USER@$IP_ADDR"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "VM created, but couldn't detect IP"
    echo "=========================================="
    echo "Check Proxmox UI for the IP address, then:"
    echo "  ssh $VM_USER@<ip-address>"
    echo "=========================================="
fi