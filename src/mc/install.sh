#!/bin/sh
set -e
export DEBIAN_FRONTEND=noninteractive

TAG=RELEASE.2026-09-16T00-00-00Z
VERSION=20260916000000.0.0

ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) SHA256=4ba2814fd5507fbe6b4d237c359750b9119d28d7217495fa5b48002fcbd397ef ;;
    arm64) SHA256=b7008ca2a1bc5735b6585981c59a3640a0daa152dc789df3d1a0d0438787de82 ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
fi

TARBALL=$(mktemp)
curl -fsSL -o "$TARBALL" "https://github.com/pgsty/mc/releases/download/${TAG}/mcli_${VERSION}_linux_${ARCH}.tar.gz"
echo "$SHA256  $TARBALL" | sha256sum -c -

# The fork names the binary `mcli`; callers expect `mc`.
tar -xzf "$TARBALL" -C /tmp mcli
install -m 0755 /tmp/mcli /usr/local/bin/mc
rm -f "$TARBALL" /tmp/mcli

mc --version
