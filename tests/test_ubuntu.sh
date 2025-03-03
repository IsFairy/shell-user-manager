#!/bin/bash
# Test shell-user-manager setup.sh on Ubuntu

set -e

# Source common test functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/test_functions.sh"

# Ubuntu specific setup
IMAGE="docker.io/ubuntu:latest"
SETUP_CMD="apt-get update && apt-get install -y bash zsh coreutils grep"

# Run the test
run_container_test "Ubuntu" "$IMAGE" "$SETUP_CMD"
exit $?