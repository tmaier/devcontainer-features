#!/bin/sh
set -e

# Update package list and install curl and ca-certificates if not available
if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
fi

# Install yek
curl -fsSL https://bodo.run/yek.sh | bash
