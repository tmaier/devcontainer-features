# Claude Code Feature

This feature installs [Claude Code](https://www.anthropic.com/claude-code), Anthropic's official CLI for AI-powered development assistance, using the [native installer](https://code.claude.com/docs/en/setup).

No Node.js dependency is required. The native installer downloads a standalone binary.

## Version Option

By default, the `latest` release channel is installed. You can also specify:

- `"stable"` — a release channel that is typically about one week behind latest, skipping releases with major regressions
- A specific semver version (e.g. `"1.0.58"`)

The channel chosen at install time becomes the default for auto-updates.

## YOLO Alias

When `yoloAlias` is set to `true`, a `yolo` shell alias is created that expands to `claude --allow-dangerously-skip-permissions`. The alias is configured for bash, zsh, and fish.

> **Warning:** `--allow-dangerously-skip-permissions` disables Claude Code's normal permission checks and confirmation prompts for potentially sensitive actions. This meaningfully reduces safety and may allow unintended or unsafe changes, so only enable `yoloAlias` if you understand and accept the security implications.
>
> If a `yolo` alias already exists in `.bashrc`/`.zshrc`, or a `yolo.fish` function file already exists, the installer will skip adding it to avoid overwriting your setup.

## Auto-Updates

The native binary automatically updates in the background. Update checks are performed on startup and periodically while running. To disable auto-updates, set the `DISABLE_AUTOUPDATER=1` environment variable.

## Persisting configuration across container rebuilds

To share your Claude Code configuration, conversation history, and credentials between your host and the Dev Container, mount `~/.claude/` into the container.

**Important:** The `plugins/` subdirectory stores hardcoded absolute paths (e.g., `/home/vscode/.claude/plugins/...`). When the same directory is read from the host (where the path is `/Users/<you>/.claude/...`), these paths are invalid, causing a `corrupted installLocation` error. To avoid this, overlay `plugins/` with a per-container Docker volume.

Add the following to your `devcontainer.json`. Replace `/home/vscode` with the actual home directory of your remote user (see `remoteUser` property).

```jsonc
  "mounts": [
    {
      "source": "${localEnv:HOME}/.claude",
      "target": "/home/vscode/.claude",
      "type": "bind"
    },
    {
      "source": "claude-plugins-${devcontainerId}",
      "target": "/home/vscode/.claude/plugins",
      "type": "volume"
    }
  ],
```

- The bind mount shares your full `~/.claude/` directory (settings, credentials, conversation history, etc.) with the container.
- The volume mount overlays `plugins/` with a named Docker volume, isolating it from the host. Docker creates this volume automatically on first use.
- `${devcontainerId}` is unique per project and stable across rebuilds, so each Dev Container gets its own plugins volume.
- `~/.claude/` must exist on the host. Run Claude Code once on your host, or create it manually: `mkdir -p ~/.claude`.

## Chrome Integration (`claude --chrome`)

Claude Code supports a Chrome integration via `claude --chrome`. To use this inside a Dev Container, combine the `claude-code` feature with the [`chrome`](https://github.com/tmaier/devcontainer-features/tree/main/src/chrome) feature configured for VNC display mode:

```jsonc
// .devcontainer/devcontainer.json
{
    "features": {
        "ghcr.io/devcontainers/features/desktop-lite:1": {},
        "ghcr.io/tmaier/devcontainer-features/chrome:2": {
            // Extensions:
            //   fdgfkebogiimcoedlicjlajpkdmockpc = Meta Pixel Helper (https://chromewebstore.google.com/detail/meta-pixel-helper/fdgfkebogiimcoedlicjlajpkdmockpc)
            //   fmkadmapgofadopljbjfkapdkoienihi = React Developer Tools (https://chromewebstore.google.com/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi)
            "extensions": "{\"fdgfkebogiimcoedlicjlajpkdmockpc\": {}, \"fmkadmapgofadopljbjfkapdkoienihi\": {}}",
            "displayMode": "vnc"
        },
        "ghcr.io/tmaier/devcontainer-features/claude-code:2": {}
    },
    "forwardPorts": [5901, 6080],
    "portsAttributes": {
        "5901": { "label": "tigervnc" },
        "6080": { "label": "novnc" }
    }
}
```

After the container starts, connect to the desktop via:
- **noVNC (browser):** http://localhost:6080
- **VNC client:** vnc://localhost:5901

Then run `claude --chrome` in the terminal to launch the Chrome integration.

## Usage

After installation, run `claude` in your project directory to get started.

For detailed documentation, see the [Claude Code documentation](https://code.claude.com/docs/en/setup).
