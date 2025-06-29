
# Google Chrome for Containers (chrome)

Installs Google Chrome with container-specific configurations and wrapper script

## Example Usage

```json
"features": {
    "ghcr.io/tmaier/devcontainer-features/chrome:1": {}
}
```



# Chrome Dev Container Feature - Additional Notes

## Description

Running Chrome in a container environment can be challenging due to sandbox, display, and security constraints. This feature installs:

1. Google Chrome stable version
2. A specialized wrapper script at `/usr/local/bin/chrome` that configures Chrome to work properly in containers
3. The necessary dependencies for Chrome to run in a container

## Important Configuration

Add the required run argument to your `devcontainer.json`:

```json
"runArgs": ["--add-host=host.docker.internal:host-gateway"]
```

> **Important**: The `--add-host=host.docker.internal:host-gateway` run argument is **required** for the Chrome wrapper to properly connect to the host machine for display forwarding and X11 connections. Without this argument, `host.docker.internal` will not resolve correctly.

## Always Use the Wrapper Script

The key component of this feature is the Chrome wrapper script located at `/usr/local/bin/chrome`. We **strongly recommend** configuring all tools to use this wrapper script rather than calling `google-chrome-stable` directly.

### For Cline

The feature automatically configures Cline to use the wrapper by setting:

```json
"cline.chromeExecutablePath": "/usr/local/bin/chrome"
```

### For Playwright

Configure Playwright to use the wrapper script:

```javascript
const browser = await playwright.chromium.launch({
  executablePath: '/usr/local/bin/chrome',
})
```

### For Puppeteer

Configure Puppeteer as follows:

```javascript
const browser = await puppeteer.launch({
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

## Technical Details

The wrapper script handles common issues with running Chrome in containers by:

- Disabling the sandbox for container compatibility
- Setting proper display configurations
- Suppressing error messages for cleaner output
- Optimizing for both headless and interactive use
- Providing special handling for debugging/Puppeteer modes
- Logging command arguments, errors, and exit codes
- Ensuring the --no-sandbox flag is always included

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

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/tmaier/devcontainer-features/blob/main/src/chrome/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
