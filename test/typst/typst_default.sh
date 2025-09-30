#!/bin/bash

# This test file will be executed against the 'typst_default' scenario
# defined in scenarios.json

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "typst command available" which typst
check "typst shows version" bash -c "typst --version"
check "typst version output format" bash -c "typst --version | grep -i 'typst'"

# Report results
reportResults