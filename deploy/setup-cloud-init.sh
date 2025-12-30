REPO_URL="https://raw.githubusercontent.com/CiaranMcAndrew/homelab/refs/heads/main"
SNIPPETS_DIR="/var/lib/vz/snippets"
mkdir -p $SNIPPETS_DIR
wget "$REPO_URL/cloud-init/meta-data.yaml" -O $SNIPPETS_DIR/meta-data.yaml
wget "$REPO_URL/cloud-init/user-data.yaml" -O $SNIPPETS_DIR/user-data.yaml