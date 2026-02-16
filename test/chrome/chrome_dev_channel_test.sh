#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome

# Dev channel checks — the apt package is "google-chrome-unstable"
check "google-chrome-unstable is installed" bash -c "command -v google-chrome-unstable"
check "google-chrome-unstable shows version" bash -c "google-chrome-unstable --version"
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has unstable binary" bash -c "grep -q 'CHROME_BINARY=\"google-chrome-unstable\"' /etc/chrome-wrapper/config"

# Wrapper should use the dev (unstable) binary
check "wrapper uses dev channel" bash -c "chrome --version | grep -i -E 'dev|canary|unstable'"

reportResults
