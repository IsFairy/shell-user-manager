#!/bin/bash
# Test profilectl functionality

set -e

echo "Starting profilectl tests..."

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Create a temporary directory for the test
TEMP_DIR=$(mktemp -d)
cp -r "$PROJECT_ROOT"/* "$TEMP_DIR"

# Create a modified setup script that installs profilectl without root check
cat > "$TEMP_DIR/setup_profilectl_test.sh" << 'EOF'
#!/bin/bash
# Modified setup script for testing profilectl

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROFILES_DIR="$HOME/.profiles"
TEMPLATES_DIR="$PROFILES_DIR/templates"
PROFILECTL_SCRIPT="$HOME/bin/profilectl"

echo "Setting up profilectl for testing..."

# Create profiles directory if it doesn't exist
if [[ ! -d "$PROFILES_DIR" ]]; then
    echo "Creating profiles directory at $PROFILES_DIR"
    mkdir -p "$PROFILES_DIR"
fi

# Create templates directory and sample templates
echo "Creating templates directory at $TEMPLATES_DIR"
mkdir -p "$TEMPLATES_DIR/basic-template"

# Create basic template files
cat > "$TEMPLATES_DIR/basic-template/.bashrc" << 'INNER_EOF'
# Basic .bashrc template for testing
echo "Test .bashrc loaded"
INNER_EOF

cat > "$TEMPLATES_DIR/basic-template/.gitconfig" << 'INNER_EOF'
[user]
    name = Test User
    email = test@example.com
[core]
    editor = nano
INNER_EOF

cat > "$TEMPLATES_DIR/basic-template/.zshrc" << 'INNER_EOF'
# Basic .zshrc template for testing
echo "Test .zshrc loaded"
INNER_EOF

# Create bin directory and install profilectl
mkdir -p "$HOME/bin"
cp "$SCRIPT_DIR/src/profilectl" "$PROFILECTL_SCRIPT"
chmod 755 "$PROFILECTL_SCRIPT"
ls -la "$HOME/bin" # Debug check

echo "profilectl setup for testing complete."
EOF

chmod +x "$TEMP_DIR/setup_profilectl_test.sh"

# Create test script for profilectl functionality
cat > "$TEMP_DIR/test_profilectl_functions.sh" << 'EOF'
#!/bin/bash
# Test profilectl commands

# Path to profilectl
PROFILECTL="$HOME/bin/profilectl"
PROFILES_DIR="$HOME/.profiles"
TEMPLATES_DIR="$PROFILES_DIR/templates"

# Function to run tests with descriptive output
run_test() {
    local test_name="$1"
    local command="$2"
    local should_succeed="$3"  # true or false
    
    echo -n "Testing $test_name... "
    
    # Run the command
    eval "$command" > /tmp/cmd_output 2>&1
    status=$?
    
    # Check if the status matches expected
    if [[ "$should_succeed" == "true" && $status -eq 0 ]] || [[ "$should_succeed" == "false" && $status -ne 0 ]]; then
        echo "PASSED"
    else
        echo "FAILED (expected success=$should_succeed, got status=$status)"
        echo "Command output: $(cat /tmp/cmd_output)"
        exit 1
    fi
}

# Ensure PATH includes the directory with profilectl
export PATH="$HOME/bin:$PATH"

echo "Checking if profilectl is available..."
if ! command -v profilectl &>/dev/null; then
    echo "profilectl not found in PATH: $PATH"
    echo "Files in $HOME/bin: $(ls -la $HOME/bin)"
    exit 1
fi

echo "Running profilectl tests..."

# Test help command
run_test "help command" "$PROFILECTL help" true

# Test list command (should show templates directory)
run_test "list command" "$PROFILECTL list" true

# Test template-list command
run_test "template-list command" "$PROFILECTL template-list" true

# Test create command with non-existent template
run_test "create with non-existent template" "$PROFILECTL create test-profile wrong-template" false

# Test create command with basic-template
run_test "create with existing template" "$PROFILECTL create test-profile basic-template" true

# Test list command again (should show new profile)
$PROFILECTL list > /tmp/list_output
if grep -q "test-profile" /tmp/list_output; then
    echo "Testing list after create... PASSED"
else
    echo "Testing list after create... FAILED (test-profile not found in output)"
    echo "Output: $(cat /tmp/list_output)"
    exit 1
fi

# Test edit command
run_test "edit command" "EDITOR=touch $PROFILECTL edit test-profile .bashrc" true

# Test delete command with incorrect confirmation
run_test "delete with reject" "echo n | $PROFILECTL delete test-profile" true

# Test creating another profile
run_test "create second profile" "$PROFILECTL create work-profile basic-template" true

# Test template-create command
run_test "template-create command" "$PROFILECTL template-create custom-template" true

# Test template-edit command
run_test "template-edit command" "EDITOR=touch $PROFILECTL template-edit custom-template .bashrc" true

# Verify template structure
if [ -d "$TEMPLATES_DIR/custom-template" ] && [ -f "$TEMPLATES_DIR/custom-template/.bashrc" ]; then
    echo "Testing template creation... PASSED"
else
    echo "Testing template creation... FAILED (custom-template or .bashrc not found)"
    exit 1
fi

# Cleanup - delete all profiles for the next test run
for profile in test-profile work-profile; do
    if [ -d "$PROFILES_DIR/$profile" ]; then
        rm -rf "$PROFILES_DIR/$profile"
    fi
done

# Delete custom template
if [ -d "$TEMPLATES_DIR/custom-template" ]; then
    rm -rf "$TEMPLATES_DIR/custom-template"
fi

echo "All profilectl tests PASSED"
EOF

chmod +x "$TEMP_DIR/test_profilectl_functions.sh"

# Run everything in a single container session to maintain HOME directory
echo -e "${YELLOW}Running profilectl tests in container...${NC}"
if ! podman run --rm -v "$TEMP_DIR:/app:Z" ubuntu:latest bash -c "
    cd /app && 
    ./setup_profilectl_test.sh && 
    chmod +x ./test_profilectl_functions.sh && 
    PATH=\$HOME/bin:\$PATH ./test_profilectl_functions.sh
"; then
    echo -e "${RED}profilectl tests failed!${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}All profilectl tests completed successfully!${NC}"
exit 0