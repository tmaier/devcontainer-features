#!/bin/bash
set -e

echo "Installing Claude Code..."

# Ensure curl is available
if ! command -v curl &> /dev/null; then
    echo "curl not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y curl
    elif command -v apk &> /dev/null; then
        apk add --no-cache curl
    elif command -v yum &> /dev/null; then
        yum install -y curl
    else
        echo "Error: curl is required but could not be installed automatically."
        exit 1
    fi
fi

# Install Claude Code using the native installer
# See https://code.claude.com/docs/en/setup
if [ -n "$_REMOTE_USER" ] && [ "$_REMOTE_USER" != "root" ]; then
    echo "Installing Claude Code for user: $_REMOTE_USER"
    su "$_REMOTE_USER" -c "curl -fsSL https://claude.ai/install.sh | bash"
else
    echo "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo "Claude Code installed successfully!"
