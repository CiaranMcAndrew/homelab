#!/bin/sh
set -e

echo "=== qBittorrent Init Container ==="
echo "Initializing qBittorrent configuration..."

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/qBittorrent/qBittorrent.conf"

# Create config directory structure
mkdir -p "$CONFIG_DIR/qBittorrent/data"
mkdir -p "$CONFIG_DIR/qBittorrent/logs"

# Check if config already exists
if [ -f "$CONFIG_FILE" ]; then
  echo "Configuration already exists at $CONFIG_FILE"
  echo "Skipping initialization to avoid overwriting existing config"
  exit 0
fi

echo "Creating new qBittorrent configuration..."

# Generate password hash
if [ -z "$QBITTORRENT_PASSWORD" ]; then
  echo "ERROR: QBITTORRENT_PASSWORD environment variable not set"
  exit 1
fi

echo "Generating password hash..."
PASSWORD_HASH=$(python3 /scripts/pwhash.py "$QBITTORRENT_PASSWORD")

# Set default username
USERNAME="${QBITTORRENT_USERNAME:-admin}"

# Create qBittorrent.conf
cat > "$CONFIG_FILE" <<EOF
[Application]
FileLogger\Enabled=true
FileLogger\Path=$CONFIG_DIR/qBittorrent/logs
FileLogger\Backup=true
FileLogger\DeleteOld=true
FileLogger\MaxSizeBytes=66560
FileLogger\Age=1
FileLogger\AgeType=1

[BitTorrent]
Session\Port=6881
Session\QueueingSystemEnabled=true
Session\MaxActiveDownloads=3
Session\MaxActiveTorrents=5
Session\MaxActiveUploads=3

[LegalNotice]
Accepted=true

[Preferences]
Advanced\RecheckOnCompletion=false
Advanced\trackerPort=9000
Connection\PortRangeMin=6881
Connection\UPnP=false
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
General\Locale=en
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelistEnabled=false
WebUI\BanDuration=3600
WebUI\CSRFProtection=false
WebUI\ClickjackingProtection=false
WebUI\HostHeaderValidation=false
WebUI\LocalHostAuth=false
WebUI\MaxAuthenticationFailCount=5
WebUI\Password_PBKDF2=$PASSWORD_HASH
WebUI\Port=8080
WebUI\ReverseProxySupportEnabled=true
WebUI\SecureCookie=false
WebUI\ServerDomains=*
WebUI\SessionTimeout=3600
WebUI\UseUPnP=false
WebUI\Username=$USERNAME
EOF

echo "✅ qBittorrent configuration created successfully!"
echo "   Username: $USERNAME"
echo "   Password: [hidden]"
echo "   Config file: $CONFIG_FILE"

# Set proper permissions
chown -R 1000:1000 "$CONFIG_DIR/qBittorrent"
chmod -R 755 "$CONFIG_DIR/qBittorrent"

echo "=== Initialization Complete ==="