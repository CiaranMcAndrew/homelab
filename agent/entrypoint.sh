#! /bin/bash
set -e

# Load environment variables
export $(cat .env | xargs)

echo "Current Directory: $(pwd)" | ts
echo "Directory Contnets: $(ls -lah .)"

# Copy terraform files to writable location
cp -r ${TF_DIR:-"/terraform"} /tmp/terraform-work
cd /tmp/terraform-work

# Get SSH public key
export SSH_PUBLIC_KEY=$(cat ${SSH_PUBLIC_KEY_PATH:-"/root/.ssh/id_rsa.pub"})

export TF_DATA_DIR="${TF_DATA_DIR:-"/tfdata"}"
mkdir -p $TF_DATA_DIR
tofu init -var "gitlab_token=${GITLAB_TOKEN}"
tofu apply -auto-approve \
    -var "gitlab_token=${GITLAB_TOKEN}" \
    -var "ssh_public_key=${SSH_PUBLIC_KEY}" \
    -var "proxmox_token_id=${PROXMOX_TOKEN_ID}" \
    -var "proxmox_token_secret=${PROXMOX_TOKEN_SECRET}" \
    -var-file="environment/${TF_ENV:-"homelab"}.tfvars"