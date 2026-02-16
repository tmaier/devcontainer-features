#!/bin/bash

# This test file will be executed against the 'chrome_extensions_inline_test' scenario
# to verify that inline per-extension config is properly applied.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

POLICY_FILE="/etc/opt/chrome/policies/managed/extension_settings.json"

# Basic Chrome checks
check "chrome wrapper script exists" test -f /usr/local/bin/chrome
check "chrome shows version" bash -c "chrome --version"

# Extension policy file exists
check "extension policy file exists" test -f "$POLICY_FILE"

# Claude extension (fcoeoabgfenejglbffodgkkbkcdhcgfn) should have global defaults
check "Claude extension has force_installed" bash -c "grep -A5 'fcoeoabgfenejglbffodgkkbkcdhcgfn' $POLICY_FILE | grep -q 'force_installed'"
check "Claude extension has force_pinned" bash -c "grep -A5 'fcoeoabgfenejglbffodgkkbkcdhcgfn' $POLICY_FILE | grep -q 'force_pinned'"
check "Claude extension has incognito allowed" bash -c "grep -A5 'fcoeoabgfenejglbffodgkkbkcdhcgfn' $POLICY_FILE | grep -q '\"incognito\": \"allowed\"'"

# uBlock Origin (cjpalhdlnbpafiamejdnhcphjbkeiagm) should have inline overrides
check "uBlock Origin has normal_installed" bash -c "grep -A5 'cjpalhdlnbpafiamejdnhcphjbkeiagm' $POLICY_FILE | grep -q 'normal_installed'"
check "uBlock Origin has unpinned" bash -c "grep -A5 'cjpalhdlnbpafiamejdnhcphjbkeiagm' $POLICY_FILE | grep -q 'unpinned'"
check "uBlock Origin has not_allowed incognito" bash -c "grep -A5 'cjpalhdlnbpafiamejdnhcphjbkeiagm' $POLICY_FILE | grep -q 'not_allowed'"

# Chromium policy should also exist
check "chromium policy file also exists" test -f /etc/chromium/policies/managed/extension_settings.json

# Report results
reportResults
