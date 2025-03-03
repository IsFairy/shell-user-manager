#!/bin/bash
# Test shell-user-manager setup.sh across different Linux distributions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "=== Testing shell-user-manager setup.sh across distributions ==="

# Check if podman is installed
if ! command -v podman &>/dev/null; then
    echo -e "${RED}Error: podman is not installed. Please install podman to run these tests.${NC}"
    exit 1
fi

# Array of distributions to test
distributions=("arch" "ubuntu" "debian" "rocky")

# Run tests for each distribution
for distro in "${distributions[@]}"; do
    echo -e "\n${YELLOW}Testing on $distro...${NC}"
    
    if "$SCRIPT_DIR/test_$distro.sh"; then
        echo -e "${GREEN}✓ $distro tests passed${NC}"
    else
        echo -e "${RED}✗ $distro tests failed${NC}"
        exit_code=1
    fi
done

if [ -z "$exit_code" ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi