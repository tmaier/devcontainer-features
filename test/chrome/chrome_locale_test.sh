#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome
check "chrome version works" bash -c "chrome --version"

# Locale config checks
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has locale de-DE" bash -c "grep -q 'LOCALE=\"de-DE\"' /etc/chrome-wrapper/config"

reportResults
