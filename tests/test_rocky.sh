#!/bin/bash
# Test shell-user-manager setup.sh on Rocky Linux

set -e

# Source common test functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/test_functions.sh"

# Rocky Linux specific setup
IMAGE="docker.io/rockylinux:latest"
SETUP_CMD="dnf -y update && dnf -y install bash zsh coreutils grep"

# Run the test
run_container_test "Rocky Linux" "$IMAGE" "$SETUP_CMD"
exit $?