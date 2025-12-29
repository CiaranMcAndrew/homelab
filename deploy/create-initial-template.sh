# Create Ubuntu cloud image template (run on Proxmox)
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

VMID=9000
qm stop $VMID
qm destroy $VMID --purge
qm create $VMID --name debian12-cloudinit
qm set $VMID --scsi0 local-lvm:0,import-from=/root/debian-12-genericcloud-amd64.qcow2

# Configure boot
qm set $VMID --boot c --bootdisk scsi0

# Add cloud-init drive
qm set $VMID --ide2 local-lvm:cloudinit

# Add serial console (helpful for debugging)
qm set $VMID --serial0 socket --vga serial0

# Start the VM
qm start $VMID
sleep 30

# Wait for boot, then access console or SSH and install
qm terminal $VMID

# Inside the VM (might need to wait for cloud-init to finish)
# Login as ubuntu/ubuntu or root if you set a password

sudo apt update
sudo apt install -y qemu-guest-agent
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent

# Shutdown
sudo shutdown -h now

# Convert back to template
qm template $VMID
