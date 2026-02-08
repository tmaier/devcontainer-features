# Claude Code Feature

This feature installs [Claude Code](https://www.anthropic.com/claude-code), Anthropic's official CLI for AI-powered development assistance, using the [native installer](https://code.claude.com/docs/en/setup).

No Node.js dependency is required. The native installer downloads a standalone binary.

## Version Option

By default, the `latest` release channel is installed. You can also specify:

- `"stable"` — a release channel that is typically about one week behind latest, skipping releases with major regressions
- A specific semver version (e.g. `"1.0.58"`)

The channel chosen at install time becomes the default for auto-updates.

## Auto-Updates

The native binary automatically updates in the background. Update checks are performed on startup and periodically while running. To disable auto-updates, set the `DISABLE_AUTOUPDATER=1` environment variable.

## Manual config for `devcontainer.json`

Mount the local `~/.claude/` directory into the Dev Container.
Add the following mount to the `devcontainer.json` file.
Replace `vscode` with the actual name of your user (see `remoteUser` property).

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
