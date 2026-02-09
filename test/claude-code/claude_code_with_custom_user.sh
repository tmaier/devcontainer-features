#!/bin/bash

# This test file will be executed against the 'claude_code_with_custom_user' scenario
# to verify that Claude Code is installed for the remote user.

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Basic functionality tests
check "claude command available" which claude
check "claude shows version" bash -c "claude --version"

# Report results
reportResults
