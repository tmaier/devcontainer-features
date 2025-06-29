#!/bin/bash

# This test file will be executed against the 'imagemagick_test' scenario
# to verify that ImageMagick is properly installed and accessible.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "convert command available" which convert
check "identify command available" which identify
check "convert shows version" bash -c "convert --version"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults