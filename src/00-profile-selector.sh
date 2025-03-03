#!/bin/bash

# Check if profiles directory exists
if [[ ! -d ~/.profiles ]]; then
    echo -e "\nError: ~/.profiles directory not found."
    echo "Please create it manually or run setup.sh again."
    return 1 2>/dev/null || exit 1
fi

# Check if there are any profiles
profiles=$(ls ~/.profiles 2>/dev/null)
if [[ -z "$profiles" ]]; then
    echo -e "\nError: No profiles found in ~/.profiles directory."
    echo "Please create at least one profile directory before using shell-user-manager."
    return 1 2>/dev/null || exit 1
fi

echo -e "\n Choose a User: \n"

select profile in $(ls ~/.profiles); do
    if [[ -z "$profile" ]]; then
        echo -e "\nNo profile selected. Exiting."
        return 1 2>/dev/null || exit 1
    elif [[ -d ~/.profiles/$profile ]]; then
        echo -e "\nChoosing $profile. Setting up\n"
        export HOME_PROFILE=~/.profiles/$profile
        break
    else
        echo "That's not a valid option. Try again."
    fi
done

# Verify that a profile was selected
if [[ -z "$profile" ]]; then
    echo -e "\nNo profile selected. Exiting."
    return 1 2>/dev/null || exit 1
fi

# Export selected profile globally
export CURRENT_PROFILE=$profile

# Set git identity using git-user-manager
if command -v git-user-manager &>/dev/null; then
    git-user-manager use "$profile"
    echo -e "\nGit identity switched to: '$profile'."
else
    echo "git-user-manager not found. Install it to manage git identities."
fi

# Optionally load profile-specific gitconfig explicitly
export GIT_CONFIG_GLOBAL="$HOME_PROFILE/.gitconfig"

# Set up oh-my-zsh environment if it exists
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    # Set ZSH environment variable for oh-my-zsh
    export ZSH="$HOME/.oh-my-zsh"
    
    # Create symlinks for custom themes and plugins if they exist in the profile
    if [[ -d "$HOME_PROFILE/.oh-my-zsh-custom" ]]; then
        export ZSH_CUSTOM="$HOME_PROFILE/.oh-my-zsh-custom"
    fi
fi

# Source user's bashrc/zshrc based on current shell
if [[ -n "$BASH" ]]; then
    if [[ -f "$HOME_PROFILE/.bashrc" ]]; then
        echo "Sourcing $HOME_PROFILE/.bashrc"
        source "$HOME_PROFILE/.bashrc"
    else
        echo "No .bashrc found in $HOME_PROFILE, using system defaults"
    fi
elif [[ -n "$ZSH_VERSION" ]]; then
    if [[ -f "$HOME_PROFILE/.zshrc" ]]; then
        echo "Sourcing $HOME_PROFILE/.zshrc"
        source "$HOME_PROFILE/.zshrc"
    else
        echo "No .zshrc found in $HOME_PROFILE, using system defaults"
    fi
else
    echo "Unknown shell type, unable to source profile-specific configuration"
fi

# Switch to zsh if .zshrc is present and we're not already in zsh
if [[ ! -n "$ZSH_VERSION" && -f "$HOME_PROFILE/.zshrc" && -x "$(command -v zsh)" ]]; then
    echo -e "\nSwitching to zsh shell..."
    export ZDOTDIR="$HOME_PROFILE"
    exec zsh -l
fi
