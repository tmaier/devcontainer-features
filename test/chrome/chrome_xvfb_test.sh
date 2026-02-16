#!/bin/bash
set -e
source dev-container-features-test-lib

check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome
check "chrome version works" bash -c "chrome --version"
check "xvfb is installed" bash -c "command -v Xvfb"
check "xdotool is installed" bash -c "command -v xdotool"
check "wmctrl is installed" bash -c "command -v wmctrl"
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has xvfb display mode" bash -c "grep -q 'DISPLAY_MODE=\"xvfb\"' /etc/chrome-wrapper/config"
check "chrome runs with virtual display" bash -c "unset DISPLAY && chrome --headless=new --dump-dom https://example.com 2>/dev/null | head -1"

reportResults
