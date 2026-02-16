#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome
check "chrome version works" bash -c "chrome --version"

# Config file checks
check "config file exists" test -f /etc/chrome-wrapper/config
check "config contains debugging port 9222" bash -c "grep -q 'DEBUGGING_PORT=\"9222\"' /etc/chrome-wrapper/config"

reportResults
