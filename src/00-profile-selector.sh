#!/bin/bash

echo -e "\n Choose a User: \n"

select profile in $(ls ~/.profiles); do
    if [[ -d ~/.profiles/$profile ]]; then
        echo -e "\nChoosing $profile. Setting up\n"
        export HOME_PROFILE=~/.profiles/$profile
        break
    else
        echo "That's not a valid option. Try again."
    fi
done

# Export selected profile globally
export CURRENT_PROFILE=$profile

# Source user's bashrc/zshrc
[[ -f "$HOME_PROFILE/.bashrc" ]] && source "$HOME_PROFILE/.bashrc"
[[ -f "$HOME_PROFILE/.zshrc" ]] && source "$HOME_PROFILE/.zshrc"

# Set git identity using git-user-manager
if command -v git-user-manager &>/dev/null; then
    git-user-manager use "$profile"
    echo -e "\nGit identity switched to: '$profile'."
else
    echo "git-user-manager not found. Install it to manage git identities."
fi

# Optionally load profile-specific gitconfig explicitly
export GIT_CONFIG_GLOBAL="$HOME_PROFILE/.gitconfig"
