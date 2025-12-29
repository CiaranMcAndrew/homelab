#!/usr/bin/env bash
set -e

IMAGE="ubuntu-22.04-server-cloudimg-amd64.img"
URL="https://cloud-images.ubuntu.com/jammy/current/${IMAGE}"

if [ ! -f "$IMAGE" ]; then
  echo "Downloading Ubuntu cloud image..."
  curl -LO "$URL"
else
  echo "Image already exists"
fi
