#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome

# Beta channel checks
check "google-chrome-beta is installed" bash -c "command -v google-chrome-beta"
check "google-chrome-beta shows version" bash -c "google-chrome-beta --version"
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has beta binary" bash -c "grep -q 'CHROME_BINARY=\"google-chrome-beta\"' /etc/chrome-wrapper/config"

# Wrapper should use the beta binary
check "wrapper uses beta channel" bash -c "chrome --version | grep -i beta"

reportResults
