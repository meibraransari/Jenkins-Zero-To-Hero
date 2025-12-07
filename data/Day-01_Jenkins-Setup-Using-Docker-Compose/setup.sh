# nano setup.sh

#!/bin/bash
set -e

# -------------------------------------
# Logging functions with emojis
# -------------------------------------
info() { echo -e "\e[34m[INFO]\e[0m 🔵 $1"; }
success() { echo -e "\e[32m[SUCCESS]\e[0m ✅ $1"; }
error() { echo -e "\e[31m[ERROR]\e[0m ❌ $1"; }

# -------------------------------------
# Validate Docker installation
# -------------------------------------
if ! command -v docker &> /dev/null; then
    error "Docker is not installed! Please install Docker before running this script."
    exit 1
fi

# Validate Docker Compose (v2)
if ! command -v docker compose &> /dev/null; then
    error "Docker Compose v2 is not installed! Install Docker Compose plugin for Docker."
    exit 1
fi

# -------------------------------------
# Check if Jenkins is already running
# -------------------------------------
if docker ps | grep -q jenkins; then
    info "Jenkins container is already running. 🚀 Nothing to do."
    exit 0
fi

# -------------------------------------
# Setup variables
# -------------------------------------
SSH_KEY_DIR="./ssh_keys"
SSH_KEY_NAME="jenkins_agent_key"
ENV_FILE=".env"
JENKINS_DATA_DIR="./jenkins_data"

# -------------------------------------
# Create SSH keys if missing
# -------------------------------------
mkdir -p "$SSH_KEY_DIR"

if [ ! -f "$SSH_KEY_DIR/$SSH_KEY_NAME" ]; then
    info "Generating SSH key pair for Jenkins agent... 🔐"
    ssh-keygen -t rsa -b 4096 -C "jenkins-agent" -f "$SSH_KEY_DIR/$SSH_KEY_NAME" -N ""
    success "SSH key pair created! 🔑"
else
    info "SSH key pair already exists. 👍"
fi

JENKINS_AGENT_SSH_PUBLIC_KEY=$(cat "$SSH_KEY_DIR/$SSH_KEY_NAME.pub")

# -------------------------------------
# Create .env file
# -------------------------------------
info "Creating environment file... 📄"

cat <<EOF > "$ENV_FILE"
JENKINS_DATA_DIR=$JENKINS_DATA_DIR
JENKINS_AGENT_SSH_PUBLIC_KEY=$JENKINS_AGENT_SSH_PUBLIC_KEY
EOF

success "Environment file created: $ENV_FILE 📦"

# -------------------------------------
# Start containers
# -------------------------------------
info "Starting Jenkins using Docker Compose... 🚀"
docker compose up -d

success "Jenkins is now running at: http://localhost:8080 🌐"
info "Using SSH private key for agent: $SSH_KEY_DIR/$SSH_KEY_NAME 🔑"

# -------------------------------------
# Display initial admin password
# -------------------------------------
info "Fetching Jenkins initial admin password (waiting 10 seconds)... ⏳"
sleep 10

docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null \
    && success "Above is your Jenkins admin password 🎉" \
    || error "Unable to retrieve admin password. Jenkins may still be starting. ⌛"