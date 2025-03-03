# Shell-User-Manager Tests

This directory contains automated tests to verify `setup.sh` works correctly across different Linux distributions using Podman containers.

## Requirements

- Podman installed on the host system
- Internet access to pull container images
- Root permissions to run the tests (since setup.sh requires root)

## Supported Distributions

The tests cover the following Linux distributions:

- Arch Linux
- Ubuntu
- Debian
- Rocky Linux

## Running Tests

To run all tests:

```bash
sudo ./run_tests.sh
```

To run tests for a specific distribution:

```bash
sudo ./test_arch.sh    # For Arch Linux
sudo ./test_ubuntu.sh  # For Ubuntu
sudo ./test_debian.sh  # For Debian
sudo ./test_rocky.sh   # For Rocky Linux
```

## Test Process

Each test performs the following steps:

1. Starts a container for the target distribution
2. Installs required packages inside the container
3. Installs a mock `git-user-manager` command
4. Runs `setup.sh` inside the container
5. Verifies the installation by checking:
   - Profile selector script in `/etc/profile.d/`
   - Bash and Zsh logout scripts
   - Profile directories creation
   - Configuration files creation
6. Cleans up the container

## Extending Tests

To add a new distribution test:

1. Create a new script `test_distroname.sh` based on an existing test
2. Update the container image and package installation commands
3. Add the new distribution to the array in `run_tests.sh`