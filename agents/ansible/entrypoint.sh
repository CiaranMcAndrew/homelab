#! /bin/bash
set -e

# Load environment variables
export $(cat .env | xargs)

echo "Current Directory: $(pwd)" | ts
echo "Directory Contnets: $(ls -lah .)"

# Get SSH public key
export SSH_PUBLIC_KEY=$(cat ${SSH_PUBLIC_KEY_PATH:-"/root/.ssh/id_rsa.pub"})

ansible-playbook -i "${ANSIBLE_INVENTORY:-/ansible/inventory.ini}" \
    "${PLAYBOOK:-/ansible/playbook.yml}" \
    --extra-vars "ssh_public_key='${SSH_PUBLIC_KEY}' portainer_admin_password='${PORTAINER_ADMIN_PASSWORD}'"