#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "node is available" which node
check "npm is available" which npm
check "codex command available" which codex
check "codex shows version" bash -c "codex --version"

# Report results
reportResults
