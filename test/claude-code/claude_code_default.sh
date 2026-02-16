#!/bin/bash

# This test file will be executed against the 'claude_code_default' scenario
# to verify that Claude Code is properly installed using the native installer.

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "claude command available" which claude
check "claude shows version" bash -c "claude --version"

# Report results
reportResults
