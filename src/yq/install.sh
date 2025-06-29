#!/bin/sh
set -e

# Update package list and install wget and ca-certificates if not available
if ! command -v wget >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends wget ca-certificates
fi

# Install yq
wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x /usr/bin/yq
