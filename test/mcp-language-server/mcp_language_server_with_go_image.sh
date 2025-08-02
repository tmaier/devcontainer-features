#!/bin/bash

# This test file will be executed against the 'mcp_language_server_with_go_image' scenario
# to verify that MCP Language Server works with Go pre-installed in the image.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "go is available" which go
check "mcp-language-server command available" which mcp-language-server
check "mcp-language-server is executable" bash -c "test -x $(which mcp-language-server)"

# Report results
reportResults