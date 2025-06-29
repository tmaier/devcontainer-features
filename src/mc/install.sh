#!/bin/sh
set -e

# Update package list and install wget and ca-certificates if not available
if ! command -v wget >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends wget ca-certificates
fi

# Install mc
wget -O /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x /usr/bin/mc
