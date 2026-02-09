
# Claude Code (claude-code)

Installs Claude Code CLI for AI-powered development assistance

## Example Usage

```json
"features": {
    "ghcr.io/tmaier/devcontainer-features/claude-code:2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Customizations

### VS Code Extensions

- `anthropic.claude-code`

# Claude Code Feature

This feature installs [Claude Code](https://www.anthropic.com/claude-code), Anthropic's official CLI for AI-powered development assistance.

Claude Code is installed using the [native installer](https://code.claude.com/docs/en/setup), which automatically keeps itself up to date.

## Manual config for `devcontainer.json`

Mount the local `~/.claude/` directory into the Dev Container.
Add the following mount to the `devcontainer.json` file.
Replace `vscode` with the actual name of your user (see `remoteUser` property)

```json
  "mounts": [
    {
      "source": "${localEnv:HOME}/.claude",
      "target": "/home/vscode/.claude",
      "type": "bind"
    }
  ],
```

## Usage

After installation, run `claude` in your project directory to get started.

For detailed documentation, see the [Claude Code documentation](https://code.claude.com/docs/en/setup).


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/tmaier/devcontainer-features/blob/main/src/claude-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
