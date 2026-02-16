#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome
check "chrome version works" bash -c "chrome --version"

# Xvfb and resolution checks
check "xvfb is installed" bash -c "command -v Xvfb"
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has xvfb display mode" bash -c "grep -q 'DISPLAY_MODE=\"xvfb\"' /etc/chrome-wrapper/config"
check "config has custom resolution 1280x720x16" bash -c "grep -q 'SCREEN_RESOLUTION=\"1280x720x16\"' /etc/chrome-wrapper/config"

reportResults
