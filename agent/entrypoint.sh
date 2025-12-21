#! /bin/bash
set -e

# Load environment variables
export $(cat .env | xargs)

echo "Current Directory: $(pwd)" | ts
echo "Directory Contnets: $(ls -lah .)"

cd ${TF_DIR:-"/terraform"}
export TF_DATA_DIR="${TF_DATA_DIR:-"/.terraform"}"
tofu init -var "gitlab_token=${GITLAB_TOKEN}"
tofu apply -auto-approve -var "gitlab_token=${GITLAB_TOKEN}"