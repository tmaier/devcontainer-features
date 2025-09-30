#!/bin/sh
set -e

echo "Installing Typst..."

# Get version from options (capitalized by devcontainer spec)
TYPST_VERSION="${VERSION:-latest}"

# Update package list and install dependencies if not available
if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
fi

if ! command -v tar >/dev/null 2>&1 || ! command -v xz >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends tar xz-utils
fi

# Construct download URL based on version
if [ "$TYPST_VERSION" = "latest" ]; then
    echo "Installing latest version of Typst..."
    DOWNLOAD_URL="https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz"
else
    echo "Installing Typst version: $TYPST_VERSION"
    DOWNLOAD_URL="https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz"
fi

# Download and extract Typst
echo "Downloading from: $DOWNLOAD_URL"
curl -fsSL -o /tmp/typst.tar.xz "$DOWNLOAD_URL"
cd /tmp
tar -xf typst.tar.xz

# Move binary to /usr/bin
mv typst-x86_64-unknown-linux-musl/typst /usr/bin/typst
chmod +x /usr/bin/typst

# Clean up
rm -rf /tmp/typst.tar.xz /tmp/typst-x86_64-unknown-linux-musl

# Verify installation
if ! command -v typst >/dev/null 2>&1; then
    echo "Error: Typst installation failed"
    exit 1
fi

INSTALLED_VERSION=$(typst --version)
echo "Typst installed successfully: $INSTALLED_VERSION"