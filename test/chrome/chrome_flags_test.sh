#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome
check "chrome version works" bash -c "chrome --version"

# Extra flags config checks
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has disable-web-security flag" bash -c "grep -q 'disable-web-security' /etc/chrome-wrapper/config"
check "config has allow-running-insecure-content flag" bash -c "grep -q 'allow-running-insecure-content' /etc/chrome-wrapper/config"

reportResults
