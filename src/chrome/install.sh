#!/bin/bash
set -e

echo "Installing Google Chrome stable version..."

# Install dependencies
apt-get update
apt-get install -y wget gnupg2 apt-transport-https ca-certificates dbus-x11

# Add Google Chrome repository
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update

# Install Google Chrome stable
apt-get install -y google-chrome-stable

echo "Creating Chrome wrapper script at /usr/local/bin/chrome..."

# Create wrapper script
cat > /usr/local/bin/chrome << 'EOF'
#!/bin/bash

# Wrapper script to run Chrome in a container environment
# addressing sandbox and display issues

# Logging setup
LOG_DIR="/var/log/chrome-wrapper"
# Fallback to user directory if system directory is not writable
if ! mkdir -p "$LOG_DIR" 2>/dev/null; then
  LOG_DIR="$HOME/.local/state/chrome-wrapper"
  mkdir -p "$LOG_DIR" 2>/dev/null || LOG_DIR="/tmp/chrome-wrapper"
  mkdir -p "$LOG_DIR" 2>/dev/null
fi
LOG_FILE="$LOG_DIR/chrome-wrapper.log"

# Logging function
log() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp - $1" >> "$LOG_FILE" 2>/dev/null
}

# Log the command invocation
log "Command: chrome $*"

# Check if DISPLAY is set
if [ -z "$DISPLAY" ]; then
  echo "DISPLAY environment variable is not set. Setting to host.docker.internal:0.0"
  export DISPLAY="host.docker.internal:0.0"
fi

# Create empty .Xauthority file if it doesn't exist
if [ ! -f ~/.Xauthority ]; then
  touch ~/.Xauthority
fi

# Disable DBus for Chrome to reduce error messages
export DBUS_SESSION_BUS_ADDRESS="disabled:"

# Check if --no-sandbox is already in the arguments
if [[ "$*" != *"--no-sandbox"* ]]; then
  log "Adding --no-sandbox flag as it was not provided"
  set -- --no-sandbox "$@"
fi

# Check if this is being called from browser_action
if [[ "$*" == *"--remote-debugging-port"* ]]; then
  # Running in Puppeteer/browser_action mode - keep remote debugging output visible
  stderr_log=$(mktemp)

  # Run Chrome and capture stderr
  google-chrome-stable \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-setuid-sandbox \
    --disable-features=VizDisplayCompositor \
    "$@" 2> >(tee "$stderr_log" >&2)

  exit_code=$?

  # Log any errors
  if [ -s "$stderr_log" ]; then
    log "STDERR: $(cat "$stderr_log")"
  fi

  # Log exit code
  log "Exit code: $exit_code"

  # Clean up
  rm -f "$stderr_log"

  # Return Chrome's exit code
  exit $exit_code
else
  # Normal mode - filter error messages for cleaner output
  # Redirect stderr to a temporary file
  local_stderr_file=$(mktemp)

  # Log the final command with all flags
  log "Final command: google-chrome-stable --no-sandbox --disable-dev-shm-usage --disable-gpu --disable-software-rasterizer --disable-setuid-sandbox --no-first-run --no-default-browser-check --no-zygote --disable-features=VizDisplayCompositor --disable-extensions --disable-background-networking --disable-sync --disable-translate --hide-scrollbars --metrics-recording-only --mute-audio --disable-dbus --headless=$([[ "$*" == *--headless* ]] || echo "new") $*"

  # Run Chrome with all the flags, redirect stderr to our temp file
  google-chrome-stable \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-setuid-sandbox \
    --no-first-run \
    --no-default-browser-check \
    --no-zygote \
    --disable-features=VizDisplayCompositor \
    --disable-extensions \
    --disable-background-networking \
    --disable-sync \
    --disable-translate \
    --hide-scrollbars \
    --metrics-recording-only \
    --mute-audio \
    --disable-dbus \
    --headless="$([[ "$*" == *--headless* ]] || echo "new")" \
    "$@" 2>"$local_stderr_file"

  # Get the exit code
  local_exit_code=$?

  # Log the exit code
  log "Exit code: $local_exit_code"

  # Check if there were any errors and log them
  if [ -s "$local_stderr_file" ]; then
    log "STDERR: $(cat "$local_stderr_file")"
  fi

  # Delete the temp file
  rm -f "$local_stderr_file"

  # Return Chrome's exit code
  exit $local_exit_code
fi
EOF

# Make the wrapper script executable
chmod +x /usr/local/bin/chrome

# Create documentation
mkdir -p /usr/local/share/chrome-wrapper
cat > /usr/local/share/chrome-wrapper/README.md << 'EOF'
# Chrome in Dev Container

This setup allows you to run Google Chrome in your Dev Container environment, addressing common sandbox and display issues.

## Usage Examples

### Headless Mode (no visible browser window)

```bash
# Dump the HTML of a webpage
chrome --dump-dom https://example.com

# Take a screenshot of a webpage
chrome --headless=new --screenshot=/tmp/screenshot.png https://example.com

# Print a webpage to PDF
chrome --headless=new --print-to-pdf=/tmp/output.pdf https://example.com
```

### Interactive Mode (requires X server on host)

Make sure you have an X server running on your host machine and that your DISPLAY variable is properly set.

```bash
# Open Chrome browser (GUI mode)
chrome https://example.com
```

## Technical Details

The wrapper script applies the following configurations to Chrome:
- Disables sandbox for container compatibility
- Optimizes for headless operation
- Suppresses common error messages related to dbus and display
- Sets up proper display configuration
- Logs command arguments, errors, and exit codes to a log file
- Ensures the --no-sandbox flag is always included

### Logging

The wrapper logs the following information to a log file:
- Command arguments used when calling the wrapper
- Any errors that occur during Chrome execution
- Exit codes

Log file location:
- Primary: `/var/log/chrome-wrapper/chrome-wrapper.log`
- Fallback: `$HOME/.local/state/chrome-wrapper/chrome-wrapper.log`
- Last resort: `/tmp/chrome-wrapper/chrome-wrapper.log`
EOF

echo "Google Chrome installation and configuration complete."
echo "NOTE: To use this feature properly, ensure your devcontainer.json includes:"
echo "      \"runArgs\": [\"--add-host=host.docker.internal:host-gateway\"]"
echo "      This is required for host.docker.internal to resolve correctly."
