#!/bin/bash

# This test file will be executed against the 'chrome_extensions_test' scenario
# to verify that Chrome extension policies are properly configured.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Basic Chrome checks
check "chrome wrapper script exists" test -f /usr/local/bin/chrome
check "chrome wrapper script is executable" test -x /usr/local/bin/chrome
check "chrome shows version" bash -c "chrome --version"

# Config file checks
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has correct binary" bash -c "grep -q 'CHROME_BINARY=\"google-chrome-stable\"' /etc/chrome-wrapper/config"

# Extension policy directory checks
check "chrome policy directory exists" test -d /etc/opt/chrome/policies/managed
check "chromium policy directory exists" test -d /etc/chromium/policies/managed

# Extension policy file checks
check "chrome extension policy file exists" test -f /etc/opt/chrome/policies/managed/extension_settings.json
check "chromium extension policy file exists" test -f /etc/chromium/policies/managed/extension_settings.json

# Policy content checks - Claude extension
check "policy contains Claude extension ID" bash -c "grep -q 'fcoeoabgfenejglbffodgkkbkcdhcgfn' /etc/opt/chrome/policies/managed/extension_settings.json"
check "policy contains force_installed" bash -c "grep -q 'force_installed' /etc/opt/chrome/policies/managed/extension_settings.json"
check "policy contains force_pinned" bash -c "grep -q 'force_pinned' /etc/opt/chrome/policies/managed/extension_settings.json"
check "policy contains update_url" bash -c "grep -q 'https://clients2.google.com/service/update2/crx' /etc/opt/chrome/policies/managed/extension_settings.json"
check "policy contains incognito allowed" bash -c "grep -q '\"incognito\": \"allowed\"' /etc/opt/chrome/policies/managed/extension_settings.json"

# Report results
reportResults
