#!/bin/sh
set -e
export DEBIAN_FRONTEND=noninteractive

# Update package list and install curl and ca-certificates if not available
if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
fi

# Install yek
curl -fsSL https://azimi.me/yek.sh | bash

# Ensure yek is accessible for all users by copying to /usr/local/bin.
# The upstream installer places the binary in a user-specific directory
# (e.g. /root/.local/bin) which is inaccessible to non-root users.
# We copy instead of symlink because /root has mode 700.
if [ ! -f /usr/local/bin/yek ]; then
    for dir in "$HOME/.yek/bin" "/root/.yek/bin" "$HOME/.local/bin" "/root/.local/bin"; do
        if [ -f "$dir/yek" ]; then
            cp "$dir/yek" /usr/local/bin/yek
            chmod 755 /usr/local/bin/yek
            break
        fi
    done
fi

if ! command -v yek >/dev/null 2>&1; then
    echo "Error: yek installation failed"
    exit 1
fi
