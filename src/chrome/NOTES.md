## What This Feature Installs

Running Chrome in a container environment can be challenging due to sandbox, display, and security constraints. This feature installs:

1. Google Chrome (stable, beta, or dev channel)
2. A specialized wrapper script at `/usr/local/bin/chrome` that configures Chrome to work properly in containers
3. The necessary dependencies for Chrome to run in a container
4. `xdotool` for X11 automation (simulating keyboard/mouse input, managing windows)
5. `wmctrl` for X Window manager control (listing, moving, resizing windows)

## Using the Chrome Wrapper

The key component is the Chrome wrapper script at `/usr/local/bin/chrome`. **Always use this wrapper** instead of calling `google-chrome-stable` directly.

### Tool Configuration

**Cline**: Automatically configured via VS Code settings.

**Puppeteer**: Auto-discovered via the `PUPPETEER_EXECUTABLE_PATH` environment variable set by this feature. No configuration needed:
```javascript
const browser = await puppeteer.launch()
```

**Karma / Angular CLI**: Auto-discovered via the `CHROME_BIN` environment variable. No configuration needed.

**Playwright**: Does not support auto-discovery via environment variables. You must pass `executablePath` explicitly:
```javascript
const browser = await playwright.chromium.launch({
  executablePath: '/usr/local/bin/chrome',
})
```

## Command Line Examples

The wrapper script supports various Chrome operations in both headless and interactive modes:

```bash
# Basic usage (headless)
chrome --headless=new https://example.com

# Get HTML content
chrome --headless=new --dump-dom https://example.com

# Take screenshots
chrome --headless=new --screenshot=/tmp/screenshot.png https://example.com

# Generate PDFs
chrome --headless=new --print-to-pdf=/tmp/output.pdf https://example.com
```

## Shared Memory for Heavy Workloads

Docker containers default to 64MB of shared memory (`/dev/shm`), which can cause Chrome to crash or produce blank screenshots under heavy workloads (many tabs, large pages, parallel tests). Increase the shared memory size via `runArgs` in your `devcontainer.json`:

```json
{
  "runArgs": ["--shm-size=2g"]
}
```

Alternatively, the wrapper script already passes `--disable-dev-shm-usage` to Chrome, which moves shared memory to `/tmp`. This works for most cases but may be slower under extreme load.

## Chrome Release Channels

Select which Chrome release channel to install using the `channel` option:

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "channel": "beta"
    }
  }
}
```

Available channels: `stable` (default), `beta`, `dev`.

## Display Modes

The `displayMode` option controls how Chrome handles display output. Three modes are available:

### headless (default)

No display server is installed. Chrome runs with `--headless=new` when no DISPLAY is set. Best for CI/CD, automated testing, and headless scraping.

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {}
  }
}
```

### xvfb (Virtual Framebuffer)

Installs Xvfb and auto-starts a virtual display on `:99` when no DISPLAY is set. Required for extensions that need a display server, and for automated testing that requires rendering.

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "displayMode": "xvfb",
      "screenResolution": "1920x1080x24"
    }
  }
}
```

> **Note**: The Xvfb display is fixed at `:99`. If you need a different display number, set the `DISPLAY` environment variable before calling `chrome` — the wrapper will use it instead of starting its own Xvfb instance.

### vnc (Desktop-Lite Integration)

Delegates to the `ghcr.io/devcontainers/features/desktop-lite` feature for a full desktop environment with VNC access. Chrome runs in GUI mode on the desktop-lite display. View Chrome via:
- **noVNC** (browser): `http://localhost:6080`
- **VNC client**: port `5901`

```json
{
  "features": {
    "ghcr.io/devcontainers/features/desktop-lite:1": {},
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "displayMode": "vnc"
    }
  }
}
```

> **Note**: VNC mode requires `desktop-lite` to be included in your devcontainer.json features. VNC password is configured via desktop-lite's `password` option (default: `vscode`).

> **Important**: `desktop-lite` defaults to 16-bit color depth (`1440x768x16`). noVNC cursor rendering requires 24-bit depth. Override the resolution to use 24-bit:
> ```json
> "ghcr.io/devcontainers/features/desktop-lite:1": {
>     "resolution": "1920x1080x24"
> }
> ```

### VNC Clipboard Sharing

Clipboard copy/paste between the host and Chrome inside a VNC session is enabled automatically when `displayMode=vnc`. The clipboard bridge uses three components:

- **vncconfig**: Bridges the VNC protocol clipboard with the X11 cutbuffer
- **autocutsel**: Syncs the X11 CLIPBOARD and PRIMARY selections with the cutbuffer
- **xclip**: Provides command-line clipboard access

Together, these create a full clipboard pipeline:

```
Host clipboard ↔ VNC protocol ↔ vncconfig ↔ X11 cutbuffer ↔ autocutsel ↔ X11 CLIPBOARD ↔ Chrome
```

#### Using clipboard with noVNC (browser)

1. Open the noVNC sidebar by clicking the arrow on the left edge of the screen
2. Open the **Clipboard** panel
3. Paste text into the clipboard panel — it becomes available to Chrome via Ctrl+V
4. Text copied in Chrome via Ctrl+C appears in the clipboard panel for copying to the host

#### Using clipboard with a native VNC client

Clipboard sharing is transparent with native VNC clients (e.g., TigerVNC Viewer, RealVNC). Ctrl+C/Ctrl+V work between the host and Chrome.

#### Command-line clipboard

`xclip` is installed for scripting clipboard access:

```bash
# Copy to clipboard
echo "text" | xclip -selection clipboard

# Paste from clipboard
xclip -selection clipboard -o
```

## Extension Management

Chrome extensions can be pre-installed via managed enterprise policies using the `extensions` option. Extensions are configured through Chrome's `ExtensionSettings` policy, which handles installation mode, toolbar pinning, and incognito access.

The `extensions` option takes a JSON object where keys are Chrome Web Store extension IDs and values are settings objects. An empty object `{}` applies the hardcoded defaults.

### Default Settings

| Key | Values | Default |
|-----|--------|---------|
| `mode` | `force_installed`, `normal_installed` | `force_installed` |
| `pin` | `true`, `false` | `true` |
| `incognito` | `force_allowed`, `allowed`, `not_allowed` | `allowed` |

### Basic Usage

Install one or more extensions with default settings:

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "extensions": "{\"fcoeoabgfenejglbffodgkkbkcdhcgfn\": {}, \"cjpalhdlnbpafiamejdnhcphjbkeiagm\": {}}"
    }
  }
}
```

### Per-Extension Settings

Override settings for individual extensions by providing values in the settings object:

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "extensions": "{\"fcoeoabgfenejglbffodgkkbkcdhcgfn\": {}, \"cjpalhdlnbpafiamejdnhcphjbkeiagm\": {\"mode\": \"normal_installed\", \"pin\": false, \"incognito\": \"not_allowed\"}}"
    }
  }
}
```

In this example:
- `fcoeoabgfenejglbffodgkkbkcdhcgfn` (Claude) uses the default settings (force installed, pinned, incognito allowed)
- `cjpalhdlnbpafiamejdnhcphjbkeiagm` (uBlock Origin) uses custom settings (normal install, unpinned, no incognito)

### Technical Details

- Extension policies are written to `/etc/opt/chrome/policies/managed/extension_settings.json` (Chrome) and `/etc/chromium/policies/managed/extension_settings.json` (Chromium)
- The wrapper script automatically detects managed policy files at runtime: if policy files exist, extensions are enabled; otherwise `--disable-extensions` is used
- Extensions are downloaded from the Chrome Web Store update URL (`https://clients2.google.com/service/update2/crx`)

## Additional Options

### Remote Debugging Port

Set a default remote debugging port that's always passed to Chrome:

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "debuggingPort": "9222"
    }
  }
}
```

### Extra Chrome Flags

Pass additional Chrome flags to every invocation:

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "chromeFlags": "--disable-web-security --allow-running-insecure-content"
    }
  }
}
```

### Fonts

Install additional font packages for proper rendering of international text, emoji, and symbols. This prevents tofu (missing glyph boxes) in screenshots and PDFs:

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "fonts": true
    }
  }
}
```

Installs: `fonts-noto-cjk` (Chinese/Japanese/Korean), `fonts-noto-color-emoji` (emoji), `fonts-liberation` (metric-compatible with Arial/Times/Courier), `fonts-dejavu-core` (extended Latin/Greek/Cyrillic).

### Locale

Set the Chrome UI language:

```json
{
  "features": {
    "ghcr.io/iot-rocket/devcontainer-features/chrome": {
      "locale": "de-DE"
    }
  }
}
```

## Technical Details

The wrapper script handles common issues with running Chrome in containers by:

- Automatically disabling the sandbox when running as root for container compatibility
- Setting proper display configurations based on display mode
- Suppressing error messages for cleaner output
- Optimizing for both headless and interactive use
- Providing special handling for debugging/Puppeteer modes
- Logging command arguments, errors, and exit codes
- Sourcing runtime config from `/etc/chrome-wrapper/config`

### Runtime Configuration

The install script writes a configuration file at `/etc/chrome-wrapper/config` that the wrapper sources at runtime. This contains the Chrome binary path, display mode, screen resolution, debugging port, extra flags, and locale settings.

### Logging

The wrapper script includes logging capabilities to help diagnose issues:

- Logs all command arguments used when calling the wrapper
- Captures and logs any errors that occur during Chrome execution
- Records exit codes for each Chrome invocation

Log files are stored in one of the following locations (in order of preference):

- `/var/log/chrome-wrapper/chrome-wrapper.log`
- `$HOME/.local/state/chrome-wrapper/chrome-wrapper.log`
- `/tmp/chrome-wrapper/chrome-wrapper.log`

For more detailed documentation, see `/usr/local/share/chrome-wrapper/README.md` after installation.
