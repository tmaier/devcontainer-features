## What This Feature Installs

Running Chrome in a container environment can be challenging due to sandbox, display, and security constraints. This feature installs:

1. Google Chrome stable version
2. A specialized wrapper script at `/usr/local/bin/chrome` that configures Chrome to work properly in containers
3. The necessary dependencies for Chrome to run in a container

## Required Configuration

**Important**: Add the required run argument to your `devcontainer.json`:

```json
"runArgs": ["--add-host=host.docker.internal:host-gateway"]
```

> The `--add-host=host.docker.internal:host-gateway` run argument is **required** for the Chrome wrapper to properly connect to the host machine for display forwarding and X11 connections.
## Using the Chrome Wrapper

The key component is the Chrome wrapper script at `/usr/local/bin/chrome`. **Always use this wrapper** instead of calling `google-chrome-stable` directly.

### Tool Configuration

**Cline**: Automatically configured via VS Code settings.

**Playwright**:
```javascript
const browser = await playwright.chromium.launch({
  executablePath: '/usr/local/bin/chrome',
})
```

**Puppeteer**:
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