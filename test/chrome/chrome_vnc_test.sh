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

# Desktop-lite integration checks
check "desktop-lite init script exists" test -f /usr/local/share/desktop-init.sh

# Xvfb should NOT be installed (vnc mode relies on desktop-lite)
check "xvfb is not installed by chrome feature" bash -c "! dpkg -l xvfb 2>/dev/null | grep -q '^ii'"

# VNC clipboard support checks
check "autocutsel is installed" bash -c "command -v autocutsel"
check "xclip is installed" bash -c "command -v xclip"
check "vncconfig is available" bash -c "command -v vncconfig"
check "config has VNC_CLIPBOARD=true" bash -c "grep -q 'VNC_CLIPBOARD=\"true\"' /etc/chrome-wrapper/config"

reportResults
