#!/bin/sh
set -e

# Update package list and install wget and ca-certificates if not available
if ! command -v wget >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends wget ca-certificates
fi

# Install adr-tools
wget -O /tmp/adr-tools.tar.gz https://github.com/npryce/adr-tools/archive/refs/tags/3.0.0.tar.gz
tar -C /usr/local/bin -xzf /tmp/adr-tools.tar.gz adr-tools-3.0.0/src
rm /tmp/adr-tools.tar.gz
