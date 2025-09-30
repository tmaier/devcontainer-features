#!/bin/bash

# This test file will be executed against the 'gemini_cli_with_node_feature' scenario
# to verify that Gemini CLI is properly installed with Node.js feature dependency.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "node is available" which node
check "npm is available" which npm
check "gemini command available" which gemini
check "gemini shows version" bash -c "gemini --version"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults