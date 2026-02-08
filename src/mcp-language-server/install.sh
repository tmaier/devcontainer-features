#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing MCP Language Server..."

# Install Go if not available
if ! command -v go &> /dev/null; then
    echo "Go not found. Installing Go via official tarball..."

    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates tar

    ARCH=$(dpkg --print-architecture)
    case "$ARCH" in
        amd64|arm64) ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    GO_VERSION="1.24.1"
    echo "Installing Go ${GO_VERSION} for ${ARCH}..."
    curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz"
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm -f /tmp/go.tar.gz

    ln -sf /usr/local/go/bin/go /usr/local/bin/go
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
    export PATH="/usr/local/go/bin:$PATH"

    rm -rf /var/lib/apt/lists/*
    echo "Go $(go version) installed successfully."
fi

# Install MCP Language Server
MCP_VERSION="${VERSION}"
if [ "$MCP_VERSION" = "latest" ] || [ -z "$MCP_VERSION" ]; then
    echo "Installing latest version of MCP Language Server..."
    go install github.com/isaacphi/mcp-language-server@latest
else
    echo "Installing MCP Language Server version: $MCP_VERSION"
    go install github.com/isaacphi/mcp-language-server@v${MCP_VERSION}
fi

# Copy binary to /usr/local/bin for system-wide access.
# go install places the binary in $GOPATH/bin (typically /root/go/bin),
# which is inaccessible to non-root users. We copy instead of symlink
# because /root has mode 700 (same approach as the yek feature).
GO_BIN_PATH="$(go env GOPATH)/bin"
if [ -f "$GO_BIN_PATH/mcp-language-server" ]; then
    cp "$GO_BIN_PATH/mcp-language-server" /usr/local/bin/mcp-language-server
    chmod 755 /usr/local/bin/mcp-language-server
else
    echo "Error: MCP Language Server installation failed"
    exit 1
fi

echo "MCP Language Server installed successfully!"
echo "Note: You will also need to install a language server for your specific programming language"
echo "Examples:"
echo "  - Go: go install golang.org/x/tools/gopls@latest"
echo "  - Rust: rustup component add rust-analyzer"
echo "  - Python: pip install pyright"
echo "  - TypeScript: npm install -g typescript-language-server"