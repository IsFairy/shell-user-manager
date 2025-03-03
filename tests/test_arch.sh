#!/bin/bash
# Test shell-user-manager setup.sh on Arch Linux

set -e

# Source common test functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/test_functions.sh"

# Arch Linux specific setup
IMAGE="docker.io/archlinux:latest"
SETUP_CMD="pacman -Syu --noconfirm && pacman -S --noconfirm bash zsh grep coreutils util-linux"

# Run the test
run_container_test "Arch Linux" "$IMAGE" "$SETUP_CMD"
exit $?