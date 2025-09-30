#!/bin/bash

# This test file will be executed against the 'typst_specific_version' scenario
# defined in scenarios.json, which installs version 0.13.1

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "typst command available" which typst
check "typst shows version" bash -c "typst --version"
check "typst version is 0.13.1" bash -c "typst --version | grep '0.13.1'"

# Report results
reportResults