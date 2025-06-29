#!/bin/bash

# This test file will be executed against the 'claude_code_with_custom_user' scenario
# to verify that Claude Code is installed globally using the remote user.

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Basic functionality tests
check "node is available" which node
check "npm is available" which npm
check "claude command available" which claude
check "claude shows version" bash -c "claude --version"

# Verify Claude Code is owned by the remote user (testuser), not root
CLAUDE_PATH=$(which claude)
check "claude binary is owned by testuser" bash -c "stat -c '%U' '$CLAUDE_PATH' | grep -q testuser"

# Verify npm global directory is owned by testuser
NPM_GLOBAL_DIR=$(npm config get prefix)
check "npm global directory is owned by testuser" bash -c "stat -c '%U' '$NPM_GLOBAL_DIR' | grep -q testuser"

# Verify Claude Code appears in user's global npm packages
check "claude appears in npm global packages" bash -c "npm list -g --depth=0 | grep -q claude"

# Report results
reportResults
