#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome

# Dev channel checks
check "google-chrome-dev is installed" bash -c "command -v google-chrome-dev"
check "google-chrome-dev shows version" bash -c "google-chrome-dev --version"
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has dev binary" bash -c "grep -q 'CHROME_BINARY=\"google-chrome-dev\"' /etc/chrome-wrapper/config"

# Wrapper should use the dev binary
check "wrapper uses dev channel" bash -c "chrome --version | grep -i dev"

reportResults
