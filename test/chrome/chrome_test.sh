#!/bin/bash

# This test file will be executed against the 'chrome_test' scenario
# to verify that Chrome is properly installed and accessible.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "chrome wrapper script exists" test -f /usr/local/bin/chrome
check "chrome wrapper script is executable" test -x /usr/local/bin/chrome
check "chrome shows version" bash -c "chrome --version"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults