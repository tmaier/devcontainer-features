#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic Chrome checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome
check "chrome version works" bash -c "chrome --version"

# Config file checks
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has vnc display mode" bash -c "grep -q 'DISPLAY_MODE=\"vnc\"' /etc/chrome-wrapper/config"
check "config has VNC_CLIPBOARD=false" bash -c "grep -q 'VNC_CLIPBOARD=\"false\"' /etc/chrome-wrapper/config"

# Negative test: clipboard tools should NOT be installed
check "autocutsel is NOT installed" bash -c "! command -v autocutsel"
check "xclip is NOT installed" bash -c "! command -v xclip"

reportResults
