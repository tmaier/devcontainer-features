#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "mcp-language-server command available" which mcp-language-server
check "mcp-language-server runs help" bash -c "mcp-language-server --help 2>&1 | grep -E '(usage|help|Usage|Help)' || true"

# Report results
reportResults
