#!/bin/bash

# This test file will be executed against the 'mcp_language_server_with_version' scenario
# to verify that MCP Language Server version option works correctly.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "go is available" which go
check "mcp-language-server command available" which mcp-language-server
check "GOPATH bin in PATH" bash -c "echo $PATH | grep -q $(go env GOPATH)/bin"

# Report results
reportResults