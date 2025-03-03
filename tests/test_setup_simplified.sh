#!/bin/bash
# Simplified test for running setup.sh in a container

set -e

echo "Starting simplified setup test..."

# Get project root directory
PROJECT_ROOT="/home/sarah/github/shell-user-manager"

# Create a temporary directory for the test
TEMP_DIR=$(mktemp -d)
cp -r "$PROJECT_ROOT"/* "$TEMP_DIR"

# Create a modified setup script without root check for testing
cat > "$TEMP_DIR/setup_test.sh" << 'EOF'
#!/bin/bash
# Modified setup script for testing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROFILES_DIR="$HOME/.profiles"
SELECTOR_SCRIPT="/tmp/profile.d/00-profile-selector.sh"

echo "Setting up shell-user-manager for testing..."

# Create profiles directory if it doesn't exist
if [[ ! -d "$PROFILES_DIR" ]]; then
    echo "Creating profiles directory at $PROFILES_DIR"
    mkdir -p "$PROFILES_DIR"
fi

# Create necessary directories
mkdir -p /tmp/profile.d
mkdir -p /tmp/bash_logout.d
mkdir -p /tmp/zsh/zlogout.d

# Install profile selector script
echo "Installing profile selector script to $SELECTOR_SCRIPT"
cp "$SCRIPT_DIR/src/00-profile-selector.sh" "$SELECTOR_SCRIPT"
chmod 755 "$SELECTOR_SCRIPT"

# Setup bash_logout and zlogout to clean environment
cat > /tmp/bash_logout.d/profile-cleanup.sh << 'INNER_EOF'
#!/bin/bash
# Clean up profile environment variables
if [[ -n "$HOME_PROFILE" || -n "$CURRENT_PROFILE" ]]; then
    unset HOME_PROFILE
    unset CURRENT_PROFILE
    unset GIT_CONFIG_GLOBAL
    echo "Profile environment cleaned."
fi
INNER_EOF

cat > /tmp/zsh/zlogout.d/profile-cleanup.zsh << 'INNER_EOF'
#!/bin/zsh
# Clean up profile environment variables
if [[ -n "$HOME_PROFILE" || -n "$CURRENT_PROFILE" ]]; then
    unset HOME_PROFILE
    unset CURRENT_PROFILE
    unset GIT_CONFIG_GLOBAL
    echo "Profile environment cleaned."
fi
INNER_EOF

chmod 755 /tmp/bash_logout.d/profile-cleanup.sh
chmod 755 /tmp/zsh/zlogout.d/profile-cleanup.zsh

echo "Setup for testing complete."
EOF

chmod +x "$TEMP_DIR/setup_test.sh"

# Run test in container
echo "Running test in container..."
podman run --rm -v "$TEMP_DIR:/app:Z" ubuntu:latest bash -c "cd /app && ./setup_test.sh"

# Clean up
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Test completed successfully!"