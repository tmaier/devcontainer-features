#!/bin/bash

# This test file will be executed against the 'adr_tools_test' scenario
# to verify that ADR Tools are properly installed and accessible.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "adr-init command available" which adr-init
check "adr command available" which adr
check "adr config help works" bash -c "adr config --help"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults