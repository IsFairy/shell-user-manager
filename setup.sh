#!/bin/bash
# Sets up the 00-profile-selector.sh, .bash_logout, and .zlogout files and checks if the .profiles directory exists.
# Also sets up profiles directories based on existing git-user-manager profiles.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROFILES_DIR="$HOME/.profiles"
SELECTOR_SCRIPT="/etc/profile.d/00-profile-selector.sh"

echo "Setting up shell-user-manager..."

# Check if running as root for system-wide installation
if [[ $EUID -ne 0 ]]; then
    echo "This script requires sudo privileges to install system-wide components."
    echo "Please run with: sudo $0"
    exit 1
fi

# Create profiles directory if it doesn't exist
if [[ ! -d "$PROFILES_DIR" ]]; then
    echo "Creating profiles directory at $PROFILES_DIR"
    mkdir -p "$PROFILES_DIR"
    chown $(logname):$(id -gn $(logname)) "$PROFILES_DIR"
fi

# Install profile selector script
echo "Installing profile selector script to $SELECTOR_SCRIPT"
cp "$SCRIPT_DIR/src/00-profile-selector.sh" "$SELECTOR_SCRIPT"
chmod 755 "$SELECTOR_SCRIPT"

# Setup bash_logout and zlogout to clean environment
cat > /etc/bash_logout.d/profile-cleanup.sh << 'EOF'
#!/bin/bash
# Clean up profile environment variables
if [[ -n "$HOME_PROFILE" || -n "$CURRENT_PROFILE" ]]; then
    unset HOME_PROFILE
    unset CURRENT_PROFILE
    unset GIT_CONFIG_GLOBAL
    echo "Profile environment cleaned."
fi
EOF

cat > /etc/zsh/zlogout.d/profile-cleanup.zsh << 'EOF'
#!/bin/zsh
# Clean up profile environment variables
if [[ -n "$HOME_PROFILE" || -n "$CURRENT_PROFILE" ]]; then
    unset HOME_PROFILE
    unset CURRENT_PROFILE
    unset GIT_CONFIG_GLOBAL
    echo "Profile environment cleaned."
fi
EOF

# Create directories for bash_logout.d and zsh/zlogout.d if they don't exist
mkdir -p /etc/bash_logout.d
mkdir -p /etc/zsh/zlogout.d

chmod 755 /etc/bash_logout.d/profile-cleanup.sh
chmod 755 /etc/zsh/zlogout.d/profile-cleanup.zsh

# Create profile directories from git-user-manager profiles if available
if command -v git-user-manager &>/dev/null; then
    echo "Detected git-user-manager, setting up profile directories..."
    profiles=$(git-user-manager list | grep -v "Available profiles" | awk '{print $1}')
    
    for profile in $profiles; do
        if [[ ! -d "$PROFILES_DIR/$profile" ]]; then
            echo "Creating profile directory for $profile"
            mkdir -p "$PROFILES_DIR/$profile"
            chown $(logname):$(id -gn $(logname)) "$PROFILES_DIR/$profile"
            
            # Create basic shell configuration files
            touch "$PROFILES_DIR/$profile/.bashrc"
            touch "$PROFILES_DIR/$profile/.zshrc"
            touch "$PROFILES_DIR/$profile/.gitconfig"
            
            chown $(logname):$(id -gn $(logname)) "$PROFILES_DIR/$profile/.bashrc"
            chown $(logname):$(id -gn $(logname)) "$PROFILES_DIR/$profile/.zshrc"
            chown $(logname):$(id -gn $(logname)) "$PROFILES_DIR/$profile/.gitconfig"
        fi
    done
else
    echo "git-user-manager not found. Install it to manage git identities."
    echo "You can create profile directories manually in $PROFILES_DIR"
fi

echo "Setup complete. You can now select profiles at login."
echo "Create new profiles by adding directories to $PROFILES_DIR"
