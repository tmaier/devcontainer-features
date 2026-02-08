#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "claude command available" which claude
check "claude shows version" bash -c "claude --version"

# Report results
reportResults
