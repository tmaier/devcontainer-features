#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing glab CLI (latest version)..."

# Ensure curl and git are available (git is a runtime dependency of glab)
apt-get update
apt-get install -y --no-install-recommends curl git ca-certificates

# Detect architecture
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64|arm64) ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Get latest version from GitLab API
LATEST_JSON=$(curl -fsSL "https://gitlab.com/api/v4/projects/34675721/releases/permalink/latest")
VERSION=$(echo "$LATEST_JSON" | sed -n 's/.*"tag_name"\s*:\s*"v\([^"]*\)".*/\1/p')

if [ -z "$VERSION" ]; then
    echo "Failed to determine latest glab version"
    exit 1
fi

echo "Latest glab version: $VERSION"

# Download and install the .deb package
DEB_URL="https://gitlab.com/gitlab-org/cli/-/releases/v${VERSION}/downloads/glab_${VERSION}_linux_${ARCH}.deb"
TMP_DEB=$(mktemp /tmp/glab_XXXXXX.deb)

echo "Downloading glab from: $DEB_URL"
curl -fsSL -o "$TMP_DEB" "$DEB_URL"

dpkg -i "$TMP_DEB"
rm -f "$TMP_DEB"

# Verify installation
if command -v glab &> /dev/null; then
    echo "glab CLI installed successfully: $(glab version)"
else
    echo "glab CLI installation failed"
    exit 1
fi
