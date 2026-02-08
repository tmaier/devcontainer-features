#!/bin/bash

# This test file will be executed against the 'gitlab_test' scenario.

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "glab is installed" which glab
check "glab version" bash -c "glab version"

# Report results
reportResults
