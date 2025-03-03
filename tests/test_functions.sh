#!/bin/bash
# Common test functions for shell-user-manager tests

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to run tests inside a container
run_container_test() {
    local distro="$1"
    local image="$2"
    local setup_cmd="$3"
    
    echo -e "${YELLOW}Starting $distro container...${NC}"
    
    # Create a container with an interactive shell
    container_id=$(podman run -d --rm -v "$PROJECT_ROOT:/app:Z" "$image" sleep infinity)
    
    if [ -z "$container_id" ]; then
        echo -e "${RED}Failed to start $distro container!${NC}"
        return 1
    fi
    
    echo "Container ID: $container_id"
    
    # Run package setup commands
    echo -e "${YELLOW}Setting up packages...${NC}"
    if ! podman exec "$container_id" bash -c "$setup_cmd"; then
        echo -e "${RED}Failed to set up packages in $distro container!${NC}"
        podman stop "$container_id" >/dev/null
        return 1
    fi
    
    # Install mock git-user-manager
    echo -e "${YELLOW}Installing mock git-user-manager...${NC}"
    podman exec "$container_id" bash -c "cat > /usr/local/bin/git-user-manager << 'EOF'
#!/bin/bash
if [ \"\$1\" = \"list\" ]; then
  echo \"Available profiles:\"
  echo \"personal     John Doe <john@example.com>\"
  echo \"work         John Doe <john@company.com>\"
fi
exit 0
EOF
chmod +x /usr/local/bin/git-user-manager"
    
    # Run the setup script
    echo -e "${YELLOW}Running setup.sh...${NC}"
    if ! podman exec "$container_id" bash -c "cd /app && ./setup.sh"; then
        echo -e "${RED}setup.sh failed on $distro!${NC}"
        podman stop "$container_id" >/dev/null
        return 1
    fi
    
    # Verify installation
    echo -e "${YELLOW}Verifying installation...${NC}"
    
    # Check profile selector script
    if ! podman exec "$container_id" bash -c "[ -f /etc/profile.d/00-profile-selector.sh ] && [ -x /etc/profile.d/00-profile-selector.sh ]"; then
        echo -e "${RED}Profile selector script not installed correctly on $distro!${NC}"
        podman stop "$container_id" >/dev/null
        return 1
    fi
    
    # Check profile logout scripts
    if ! podman exec "$container_id" bash -c "[ -f /etc/bash_logout.d/profile-cleanup.sh ] && [ -x /etc/bash_logout.d/profile-cleanup.sh ]"; then
        echo -e "${RED}Bash logout script not installed correctly on $distro!${NC}"
        podman stop "$container_id" >/dev/null
        return 1
    fi
    
    if ! podman exec "$container_id" bash -c "[ -f /etc/zsh/zlogout.d/profile-cleanup.zsh ] && [ -x /etc/zsh/zlogout.d/profile-cleanup.zsh ]"; then
        echo -e "${RED}Zsh logout script not installed correctly on $distro!${NC}"
        podman stop "$container_id" >/dev/null
        return 1
    fi
    
    # Check profiles directory
    if ! podman exec "$container_id" bash -c "[ -d /root/.profiles ] && [ -d /root/.profiles/personal ] && [ -d /root/.profiles/work ]"; then
        echo -e "${RED}Profile directories not created correctly on $distro!${NC}"
        podman stop "$container_id" >/dev/null
        return 1
    fi
    
    # Check shell configuration files
    if ! podman exec "$container_id" bash -c "[ -f /root/.profiles/personal/.bashrc ] && [ -f /root/.profiles/personal/.zshrc ] && [ -f /root/.profiles/personal/.gitconfig ]"; then
        echo -e "${RED}Profile configuration files not created correctly on $distro!${NC}"
        podman stop "$container_id" >/dev/null
        return 1
    fi
    
    # Clean up
    echo -e "${YELLOW}Cleaning up $distro container...${NC}"
    podman stop "$container_id" >/dev/null
    
    echo -e "${GREEN}All tests passed for $distro!${NC}"
    return 0
}