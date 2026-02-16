#!/bin/bash
set -e
source dev-container-features-test-lib

# Basic checks
check "chrome wrapper exists" test -f /usr/local/bin/chrome
check "chrome wrapper is executable" test -x /usr/local/bin/chrome
check "chrome version works" bash -c "chrome --version"

# Combined config checks - debugging port + locale + chromeFlags
check "config file exists" test -f /etc/chrome-wrapper/config
check "config has debugging port 9222" bash -c "grep -q 'DEBUGGING_PORT=\"9222\"' /etc/chrome-wrapper/config"
check "config has locale fr-FR" bash -c "grep -q 'LOCALE=\"fr-FR\"' /etc/chrome-wrapper/config"
check "config has disable-web-security flag" bash -c "grep -q 'disable-web-security' /etc/chrome-wrapper/config"

# Environment variable checks
check "CHROME_BIN env var is set" bash -c "test -n \"\$CHROME_BIN\""
check "CHROME_BIN points to wrapper" bash -c "test \"\$CHROME_BIN\" = '/usr/local/bin/chrome'"
check "PUPPETEER_EXECUTABLE_PATH is set" bash -c "test -n \"\$PUPPETEER_EXECUTABLE_PATH\""
check "PUPPETEER_EXECUTABLE_PATH points to wrapper" bash -c "test \"\$PUPPETEER_EXECUTABLE_PATH\" = '/usr/local/bin/chrome'"

reportResults
