#! /bin/bash
set -e

if [ ! -d /git/homelab/.git ]; then
    echo 'Cloning repository...';
    git clone --branch \"$$GIT_BRANCH\" \"$$GIT_REPO\" /git/homelab;
fi;
cd /git/homelab;
while true; do
    echo 'Pulling latest changes...';
    git pull origin \"$$GIT_BRANCH\";
    sleep $$SLEEP_INTERVAL;
done

echo "Copying pihole configuration data...";
cp -r /git/homelab/applications/pihole/config/* /etc/pihole/;