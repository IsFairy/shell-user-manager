# Shell-User-Manager Tests

This directory contains tests to verify `setup.sh` works correctly across different Linux distributions using Podman containers.

## Requirements

- Podman installed on the host system
- Internet access to pull container images

## Testing Approach

The tests use a simplified approach to validate the shell-user-manager script:

1. `test_setup_simplified.sh`: A focused test that validates the core functionality in a non-root environment by using temporary directories.

For full integration testing in your environment, it's recommended to manually test the setup.sh script with sudo privileges after reviewing the code.

## Running the Tests

To run all tests:

```bash
./run_tests.sh
```

This will run the profilectl test followed by the distribution-specific tests.

### Simplified Setup Test

To run just the simplified setup test:

```bash
./test_setup_simplified.sh
```

This test:
1. Creates a temporary testing environment
2. Copies the project files
3. Creates a modified setup script that writes to temporary directories
4. Executes the script in an Ubuntu container
5. Verifies the basic functionality

### profilectl Test

To run the profilectl test separately:

```bash
./test_profilectl.sh
```

This test:
1. Creates a temporary testing environment
2. Sets up the profilectl command and templates
3. Tests all profilectl commands (create, list, delete, edit, template management)
4. Verifies profile and template creation/modification

## Manual Testing on Different Distributions

The tests directory includes scripts for testing on various distributions. Due to the need for root privileges and system modifications, we recommend:

1. Review the test scripts to understand the testing process
2. Manually test on your target distributions after code review
3. Use VMs or containers in your own environment for full system testing

Supported test scripts:
- `test_profilectl.sh` - Tests the profilectl command functionality
- `test_arch.sh` - Tests setup.sh on Arch Linux
- `test_ubuntu.sh` - Tests setup.sh on Ubuntu
- `test_debian.sh` - Tests setup.sh on Debian
- `test_rocky.sh` - Tests setup.sh on Rocky Linux
- `test_setup_simplified.sh` - Simplified environment test
- `test_functions.sh` - Common functions used by the distribution tests

## Notes on Testing System Scripts

Because shell-user-manager modifies system directories like `/etc/profile.d/`, complete testing requires:

1. Root privileges
2. System modifications
3. User environment changes

The simplified test verifies core functionality without these requirements, making it suitable for CI/CD pipelines and quick validation.