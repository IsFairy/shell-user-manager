#!/bin/bash
# Simple test for shell-user-manager setup.sh on Ubuntu

# Use set -x for debugging
set -x

echo "Starting simple Ubuntu test..."

# Get project root directory
PROJECT_ROOT="/home/sarah/github/shell-user-manager"

# Test running a simple container command
echo "Testing basic container execution..."
podman run --rm docker.io/ubuntu:latest echo "Container test successful"

# Test mounting the directory
echo "Testing directory mounting..."
podman run --rm -v "$PROJECT_ROOT:/app:Z" docker.io/ubuntu:latest ls -la /app

# Test installing packages
echo "Testing package installation..."
podman run --rm docker.io/ubuntu:latest bash -c "apt-get update && apt-get install -y bash"

# Testing only the setup.sh content
echo "Testing setup.sh content..."
cat "$PROJECT_ROOT/setup.sh"

echo "Test completed"