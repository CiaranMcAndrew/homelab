#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Configuration
# ----------------------------
VMID=9000
VM_NAME="debian-12-template"
STORAGE="local-lvm"
TEMPLATE_DIR="/var/lib/vz/template/iso"
SNIPPETS_DIR="/var/lib/vz/snippets"
IMAGE="debian-12-genericcloud-amd64.qcow2"
URL="https://cdimage.debian.org/images/cloud/bookworm/latest/${IMAGE}"
MEMORY=2048
CORES=2
BRIDGE="vmbr0"
SSH_KEY="$HOME/.ssh/id_rsa.pub"

# ----------------------------
# Prepare directories
# ----------------------------
mkdir -p "$TEMPLATE_DIR" "$SNIPPETS_DIR"
cd "$TEMPLATE_DIR"

# ----------------------------
# Download image if missing
# ----------------------------
ls -lah $IMAGE || true
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
# Cloud-init user
# ----------------------------
qm set "$VMID" \
  --ciuser automation \
  --sshkey "$SSH_KEY" \
  --ipconfig0 ip=dhcp


# ----------------------------
# Cloud-init custom snippet
# ----------------------------
cat << 'EOF' > "$SNIPPETS_DIR/base.yaml"
#cloud-config
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF

qm set "$VMID" --cicustom "user=local:snippets/base.yaml"

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
    sleep 10
done

if [ "$AGENT_OK" -ne 1 ]; then
    echo "ERROR: QEMU Guest Agent never came up"
    exit 1
fi

# ----------------------------
# Shutdown and convert to template
# ----------------------------
echo "Shutting down VM..."
qm shutdown "$VMID"

# Wait until VM is fully off
while qm status "$VMID" | grep -q running; do
    sleep 5
done

echo "Converting VM to template..."
qm template "$VMID"

echo "Template $VM_NAME (VMID $VMID) created successfully!"
