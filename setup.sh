#!/bin/bash
# Sets up the 00-profile-selector.sh, .bash_logout, and .zlogout files and checks if the .profiles directory exists.
# Also sets up profiles directories based on existing git-user-manager profiles.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROFILES_DIR="$HOME/.profiles"
TEMPLATES_DIR="$PROFILES_DIR/templates"
SELECTOR_SCRIPT="/etc/profile.d/00-profile-selector.sh"
PROFILECTL_SCRIPT="/usr/local/bin/profilectl"

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

# Create templates directory and sample templates
echo "Creating templates directory at $TEMPLATES_DIR"
mkdir -p "$TEMPLATES_DIR/basic-template"
chown -R $(logname):$(id -gn $(logname)) "$TEMPLATES_DIR"

# Create basic template files
cat > "$TEMPLATES_DIR/basic-template/.bashrc" << 'EOF'
# Basic .bashrc template
# You can customize this file for your shell environment

# Set default editor
export EDITOR=nano

# Set custom prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Add aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add your custom configurations below
EOF

cat > "$TEMPLATES_DIR/basic-template/.gitconfig" << 'EOF'
[user]
    name = Your Name
    email = your.email@example.com
[core]
    editor = nano
[color]
    ui = auto
[init]
    defaultBranch = main
EOF

# Create zshrc template file
cat > "$TEMPLATES_DIR/basic-template/.zshrc" << 'EOF'
# Basic .zshrc template
# You can customize this file for your shell environment

# Set default editor
export EDITOR=nano

# Set up history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Use emacs keybindings
bindkey -e

# Basic zsh completion
autoload -Uz compinit
compinit

# Set custom prompt
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Add aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Check if oh-my-zsh is installed and use it
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  export ZSH_CUSTOM="$HOME_PROFILE/.oh-my-zsh-custom"
  ZSH_THEME="robbyrussell"
  plugins=(git)
  source $ZSH/oh-my-zsh.sh
fi

# Add your custom configurations below
EOF

# Set permissions for template files
chmod 644 "$TEMPLATES_DIR/basic-template/.bashrc"
chmod 644 "$TEMPLATES_DIR/basic-template/.gitconfig"
chmod 644 "$TEMPLATES_DIR/basic-template/.zshrc"
chown -R $(logname):$(id -gn $(logname)) "$TEMPLATES_DIR/basic-template"

# Install profile selector script
echo "Installing profile selector script to $SELECTOR_SCRIPT"
cp "$SCRIPT_DIR/src/00-profile-selector.sh" "$SELECTOR_SCRIPT"
chmod 755 "$SELECTOR_SCRIPT"

# Install profilectl command
echo "Installing profilectl command to $PROFILECTL_SCRIPT"
cp "$SCRIPT_DIR/src/profilectl" "$PROFILECTL_SCRIPT"
chmod 755 "$PROFILECTL_SCRIPT"

# Create directories for bash_logout.d and zsh/zlogout.d if they don't exist
mkdir -p /etc/bash_logout.d
mkdir -p /etc/zsh/zlogout.d

# Setup bash_logout and zlogout to clean environment
cat > /etc/bash_logout.d/profile-cleanup.sh << 'EOF'
#!/bin/bash
# Clean up profile environment variables
if [[ -n "$HOME_PROFILE" || -n "$CURRENT_PROFILE" ]]; then
    echo "Cleaning up profile environment..."
    # Profile variables
    unset HOME_PROFILE
    unset CURRENT_PROFILE
    
    # Git variables
    unset GIT_CONFIG_GLOBAL
    
    # oh-my-zsh variables
    unset ZSH_CUSTOM
    
    # zsh variables
    unset ZDOTDIR
    
    echo "Profile environment cleaned."
fi
EOF

cat > /etc/zsh/zlogout.d/profile-cleanup.zsh << 'EOF'
#!/bin/zsh
# Clean up profile environment variables
if [[ -n "$HOME_PROFILE" || -n "$CURRENT_PROFILE" ]]; then
    echo "Cleaning up profile environment..."
    # Profile variables
    unset HOME_PROFILE
    unset CURRENT_PROFILE
    
    # Git variables
    unset GIT_CONFIG_GLOBAL
    
    # oh-my-zsh variables
    unset ZSH_CUSTOM
    
    # zsh variables
    unset ZDOTDIR
    
    echo "Profile environment cleaned."
fi
EOF

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
            
            # Create oh-my-zsh custom directory if oh-my-zsh is installed
            if [[ -d "/home/$(logname)/.oh-my-zsh" ]]; then
                echo "Detected oh-my-zsh, creating custom directory for $profile"
                mkdir -p "$PROFILES_DIR/$profile/.oh-my-zsh-custom/themes"
                mkdir -p "$PROFILES_DIR/$profile/.oh-my-zsh-custom/plugins"
                
                # Create a sample .zshrc with oh-my-zsh configuration if it doesn't exist
                if [[ ! -s "$PROFILES_DIR/$profile/.zshrc" ]]; then
                    cat > "$PROFILES_DIR/$profile/.zshrc" << 'EOF'
# Path to oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# Set profile-specific custom directory
export ZSH_CUSTOM=$HOME_PROFILE/.oh-my-zsh-custom

# Set theme
ZSH_THEME="robbyrussell"

# Set plugins
plugins=(git)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# User configuration below
EOF
                fi
                
                chown -R $(logname):$(id -gn $(logname)) "$PROFILES_DIR/$profile/.oh-my-zsh-custom"
            fi
            
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
echo "Manage profiles with the profilectl command:"
echo "  profilectl create <username> [template]   - Create new profile"
echo "  profilectl delete <username>              - Delete a profile"
echo "  profilectl edit <username> [filename]     - Edit profile files"
echo "  profilectl list                           - List profiles"
echo ""
echo "Manage templates with:"
echo "  profilectl template-list                  - List templates"
echo "  profilectl template-create <name>         - Create new template"
echo "  profilectl template-edit <name> [file]    - Edit template"
echo ""
echo "Templates are stored in $TEMPLATES_DIR"