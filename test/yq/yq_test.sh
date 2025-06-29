#!/bin/bash

# This test file will be executed against the 'yq_test' scenario
# to verify that yq is properly installed and accessible.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "yq command available" which yq
check "yq shows version" bash -c "yq --version"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults