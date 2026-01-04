#! /bin/bash
set -e

# Load environment variables
export $(cat .env | xargs)

echo "Current Directory: $(pwd)" | ts
echo "Directory Contents: $(ls -lah .)"

# Copy terraform files to writable location
cp -r ${TF_DIR:-"/terraform"} /tmp/terraform-work
cd /tmp/terraform-work
echo "Working directory contents: " | ts
ls -lah .

# Get SSH public key
export SSH_PUBLIC_KEY=$(cat ${SSH_PUBLIC_KEY_PATH:-"/root/.ssh/id_rsa.pub"})
echo "Using SSH Public Key: ${SSH_PUBLIC_KEY}" | ts

export TF_DATA_DIR="${TF_DATA_DIR:-"/tfdata"}"
mkdir -p $TF_DATA_DIR
echo "Using TF Data Directory: ${TF_DATA_DIR}" | ts

echo "Initializing OpenTofu..." | ts
tofu init -var "gitlab_token=${GITLAB_TOKEN}"

# Verify initialization
echo "Checking initialization..." | ts
ls -la $TF_DATA_DIR
ls -la .terraform 2>/dev/null || echo "No local .terraform dir"

echo "Applying OpenTofu configuration..." | ts
tofu apply -auto-approve 