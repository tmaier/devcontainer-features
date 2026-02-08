#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "node is available" which node
check "npm is available" which npm
check "gemini command available" which gemini
check "gemini shows version" bash -c "gemini --version"

# Report results
reportResults
