#!/bin/bash

# This test file will be executed against the 'codex_with_node_image' scenario
# to verify that Codex CLI is properly installed on a Node.js base image.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "node is available" which node
check "npm is available" which npm
check "codex command available" which codex
check "codex shows version" bash -c "codex --version"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults