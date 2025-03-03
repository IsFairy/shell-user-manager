#!/bin/bash

echo -e "\nCleaning up...\n"

# Unset profile-specific variables
unset HOME_PROFILE
unset CURRENT_PROFILE
unset GIT_CONFIG_GLOBAL

# Optional: reset git identity to a neutral/default user
if command -v git-user-manager &>/dev/null; then
    git-user-manager reset
    echo -e "Git identity reset to default.\n"
fi
