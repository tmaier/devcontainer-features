#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'gemini-cli' Feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "gemini command available" which gemini
check "gemini shows version" bash -c "gemini --version"

# Report results
reportResults
