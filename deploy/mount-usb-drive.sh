# === ON PROXMOX HOST ===

# 1. Connect USB SSD and identify
lsblk
# Note device name (e.g., /dev/sdc)

# 2. Format drive
parted /dev/sdb --script mklabel gpt
parted /dev/sdb --script mkpart primary ext4 0% 100%
mkfs.ext4 -L media /dev/sdb1

# 3. Create mount point
mkdir -p /mnt/usb-media

# 4. Get UUID
UUID=$(blkid -s UUID -o value /dev/sdb1)
echo "UUID=$UUID /mnt/usb-media ext4 defaults,nofail 0 2" >> /etc/fstab

# 5. Mount
mount -a
df -h /mnt/usb-media

# 6. Set permissions
chown 1000:1000 /mnt/usb-media
chmod 755 /mnt/usb-media

# 7. Create directory structure
mkdir -p /mnt/usb-media/{tv,movies,downloads}
