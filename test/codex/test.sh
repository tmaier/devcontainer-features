#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'codex' Feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "codex command available" which codex
check "codex shows version" bash -c "codex --version"

# Report results
reportResults
