#!/bin/bash
set -e

echo "Installing MCP Language Server..."

# Check if Go is available
if ! command -v go &> /dev/null; then
    echo "Error: Go is required but not found. Please ensure the Go feature is installed."
    exit 1
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

# Ensure Go bin directory is in PATH
GO_BIN_PATH=$(go env GOPATH)/bin
if ! echo "$PATH" | grep -q "$GO_BIN_PATH"; then
    echo "Adding Go bin directory to PATH..."
    echo "export PATH=\"\$PATH:$GO_BIN_PATH\"" >> /etc/bash.bashrc
    export PATH="$PATH:$GO_BIN_PATH"
fi

# Verify installation
if ! command -v mcp-language-server &> /dev/null; then
    # Check if it's available in GOPATH/bin
    if [ -f "$GO_BIN_PATH/mcp-language-server" ]; then
        echo "MCP Language Server installed to $GO_BIN_PATH/mcp-language-server"
        # Create a symlink to make it globally available
        ln -sf "$GO_BIN_PATH/mcp-language-server" /usr/local/bin/mcp-language-server
    else
        echo "Error: MCP Language Server installation failed"
        exit 1
    fi
fi

echo "MCP Language Server installed successfully!"
echo "Note: You will also need to install a language server for your specific programming language"
echo "Examples:"
echo "  - Go: go install golang.org/x/tools/gopls@latest"
echo "  - Rust: rustup component add rust-analyzer"
echo "  - Python: pip install pyright"
echo "  - TypeScript: npm install -g typescript-language-server"