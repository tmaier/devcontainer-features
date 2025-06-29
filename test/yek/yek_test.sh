#!/bin/bash

# This test file will be executed against the 'yek_test' scenario
# to verify that yek is properly installed and accessible.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "yek command available" which yek
check "yek shows help" bash -c "yek --help"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults