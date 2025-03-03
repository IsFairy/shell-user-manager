#!/bin/bash
# Test shell-user-manager setup.sh on Debian

set -e

# Source common test functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/test_functions.sh"

# Debian specific setup
IMAGE="docker.io/debian:stable"
SETUP_CMD="apt-get update && apt-get install -y bash zsh coreutils grep"

# Run the test
run_container_test "Debian" "$IMAGE" "$SETUP_CMD"
exit $?