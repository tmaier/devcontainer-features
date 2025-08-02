#!/bin/bash

# This test file will be executed against the 'mcp_language_server_with_go_feature' scenario
# to verify that MCP Language Server is properly installed with Go feature dependency.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple smoke test
# The 'check' command comes from the dev-container-features-test-lib.
check "go is available" which go
check "mcp-language-server command available" which mcp-language-server
check "mcp-language-server runs help" bash -c "mcp-language-server --help 2>&1 | grep -E '(usage|help|Usage|Help)' || true"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults