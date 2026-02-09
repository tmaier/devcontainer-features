#!/bin/bash

# This test file will be executed against the 'claude_code_default' scenario
# to verify that Claude Code is properly installed using the native installer.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "claude command available" which claude
check "claude shows version" bash -c "claude --version"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
