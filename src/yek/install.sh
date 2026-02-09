#!/bin/sh
set -e

# Update package list and install curl and ca-certificates if not available
if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
fi

# Install yek
curl -fsSL https://azimi.me/yek.sh | bash

# The installer places the binary in ~/.local/bin which may not be in PATH.
# Copy it to /usr/local/bin to ensure it's globally available.
if [ -f "$HOME/.local/bin/yek" ] && ! command -v yek >/dev/null 2>&1; then
    cp "$HOME/.local/bin/yek" /usr/local/bin/yek
    chmod +x /usr/local/bin/yek
fi
