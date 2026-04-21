#!/bin/bash

# This test file will be executed against the 'claude_code_yolo_alias' scenario
# to verify that the yolo alias is properly configured.

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "claude command available" which claude
check "yolo alias in bashrc" bash -c "grep -q 'alias yolo=' ~/.bashrc"
check "yolo alias in zshrc" bash -c "grep -q 'alias yolo=' ~/.zshrc"
check "fish yolo function exists" bash -c "test -f ~/.config/fish/functions/yolo.fish"
check "yolo resolves in bash" bash -ic "type yolo"

# Report results
reportResults
