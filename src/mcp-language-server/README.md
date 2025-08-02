
# MCP Language Server (mcp-language-server)

Installs MCP Language Server - runs and exposes language servers to LLMs for semantic code navigation

## Example Usage

```json
"features": {
    "ghcr.io/tmaier/devcontainer-features/mcp-language-server:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of MCP Language Server to install. Use 'latest' for the latest version. | string | latest |

# MCP Language Server Feature

This feature installs [MCP Language Server](https://github.com/isaacphi/mcp-language-server), which runs and exposes language servers to LLMs for semantic code navigation.

## Requirements

- Go
- A language server for your programming language (installed separately)

## Supported Language Servers

- **Go**: `go install golang.org/x/tools/gopls@latest`
- **Rust**: `rustup component add rust-analyzer`
- **Python**: `pip install pyright`
- **TypeScript**: `npm install -g typescript-language-server`
- **C/C++**: `clangd` (via system package manager)

## Usage

After installation, configure MCP Language Server in your MCP client settings:

```json
{
  "mcpServers": {
    "language-server": {
      "command": "mcp-language-server",
      "args": ["--language-server", "gopls", "serve", "--root-uri", "file:///path/to/project"]
    }
  }
}
```

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/tmaier/devcontainer-features/blob/main/src/mcp-language-server/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
