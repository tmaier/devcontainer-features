#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'gitlab' Feature with no options.

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "glab is installed" which glab
check "glab version" bash -c "glab version"

# Report results
reportResults
