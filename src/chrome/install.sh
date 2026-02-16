#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# =============================================================================
# Section 1: Package Installation
# =============================================================================

# Chrome only ships for amd64 — detect arch and exit early on unsupported platforms
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) ;;
    *)
        echo "ERROR: Google Chrome is only available for amd64, but this system is ${ARCH}."
        exit 1
        ;;
esac

CHANNEL="${CHANNEL:-stable}"
CHROME_PACKAGE="google-chrome-${CHANNEL}"

echo "Installing Google Chrome (${CHANNEL} channel)..."

# Install dependencies
apt-get update
apt-get install -y --no-install-recommends wget gnupg2 apt-transport-https ca-certificates dbus-x11 xdotool wmctrl jq

# Add Google Chrome repository (using modern signed-by approach)
mkdir -p /etc/apt/keyrings
wget -q -O /etc/apt/keyrings/google-chrome.asc https://dl.google.com/linux/linux_signing_key.pub
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.asc] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update

# Install Google Chrome
apt-get install -y --no-install-recommends "$CHROME_PACKAGE"

# Verify Chrome installed correctly
if ! command -v "$CHROME_PACKAGE" >/dev/null 2>&1; then
  echo "ERROR: ${CHROME_PACKAGE} binary not found after installation."
  exit 1
fi
echo "Chrome version: $("$CHROME_PACKAGE" --version)"

# Install display-mode specific packages
case "${DISPLAYMODE:-headless}" in
  xvfb)
    echo "Installing Xvfb for virtual display support..."
    apt-get install -y --no-install-recommends xvfb
    echo "Xvfb installed successfully."
    ;;
  vnc)
    echo "Installing cursor theme for VNC display..."
    apt-get install -y --no-install-recommends adwaita-icon-theme
    # Configure system-wide default cursor theme
    mkdir -p /usr/share/icons/default
    cat > /usr/share/icons/default/index.theme << CURSOREOF
[Icon Theme]
Inherits=Adwaita
CURSOREOF
    # Configure GTK3 cursor theme for Chrome
    mkdir -p /etc/gtk-3.0
    cat > /etc/gtk-3.0/settings.ini << GTKEOF
[Settings]
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
GTKEOF
    if [ "${VNCCLIPBOARD:-true}" = "true" ]; then
      echo "Installing VNC clipboard support packages..."
      apt-get install -y --no-install-recommends autocutsel xclip
      echo "VNC clipboard packages installed successfully."
    fi
    # Desktop-lite provides VNC infrastructure
    if [ ! -f /usr/local/share/desktop-init.sh ]; then
      echo "WARNING: displayMode=vnc requires the 'ghcr.io/devcontainers/features/desktop-lite' feature."
      echo "Add it to your devcontainer.json features to enable VNC access."
    fi
    ;;
esac

# Install optional font packages for proper rendering in screenshots/PDFs
if [ "${FONTS:-false}" = "true" ]; then
  echo "Installing font packages for CJK, emoji, and Latin rendering..."
  apt-get install -y --no-install-recommends fonts-noto-cjk fonts-noto-color-emoji fonts-liberation fonts-dejavu-core
  echo "Font packages installed successfully."
fi

# Clean up APT cache to reduce image size
apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Section 2: Runtime Config File
# =============================================================================

# Validate screenResolution format when xvfb mode is selected
if [ "${DISPLAYMODE:-headless}" = "xvfb" ]; then
  if ! echo "${SCREENRESOLUTION:-1920x1080x24}" | grep -qE '^[0-9]+x[0-9]+x[0-9]+$'; then
    echo "ERROR: screenResolution '${SCREENRESOLUTION}' does not match expected WIDTHxHEIGHTxDEPTH format (e.g. 1920x1080x24)."
    exit 1
  fi
fi

echo "Writing runtime configuration..."
mkdir -p /etc/chrome-wrapper
cat > /etc/chrome-wrapper/config << CONFIGEOF
CHROME_BINARY="${CHROME_PACKAGE}"
DISPLAY_MODE="${DISPLAYMODE:-headless}"
SCREEN_RESOLUTION="${SCREENRESOLUTION:-1920x1080x24}"
DEBUGGING_PORT="${DEBUGGINGPORT:-}"
EXTRA_FLAGS="${CHROMEFLAGS:-}"
LOCALE="${LOCALE:-}"
VNC_CLIPBOARD="$([ "${DISPLAYMODE:-headless}" = "vnc" ] && [ "${VNCCLIPBOARD:-true}" = "true" ] && echo "true" || echo "false")"
CONFIGEOF

echo "Runtime config written to /etc/chrome-wrapper/config"

# =============================================================================
# Section 3: Extension Policy Generation
# =============================================================================

if [ -n "${EXTENSIONS}" ]; then
  echo "Configuring Chrome extension policies..."

  # The devcontainer CLI may strip double quotes from JSON option values when
  # generating the install wrapper script. Detect and repair corrupted JSON.
  if ! echo "$EXTENSIONS" | jq empty 2>/dev/null; then
    echo "Repairing extension JSON (quotes stripped by devcontainer CLI)..."
    EXTENSIONS=$(echo "$EXTENSIONS" | sed -E \
      -e 's/([{,]) *([a-zA-Z_][a-zA-Z0-9_]*) *:/\1"\2":/g' \
      -e 's/: *([a-zA-Z_][a-zA-Z0-9_]*) *([,}])/: "\1"\2/g' \
      -e 's/"(true|false|null)"/\1/g')
  fi

  CHROME_UPDATE_URL="https://clients2.google.com/service/update2/crx"

  # Build ExtensionSettings policy from JSON input using jq
  POLICY_JSON=$(echo "$EXTENSIONS" | jq -r --arg update_url "$CHROME_UPDATE_URL" '
    {
      "ExtensionSettings": (
        to_entries | map(
          {
            key: .key,
            value: {
              "installation_mode": (.value.mode // "force_installed"),
              "update_url": $update_url,
              "toolbar_pin": (if (.value | has("pin")) then (if .value.pin then "force_pinned" else "unpinned" end) else "force_pinned" end),
              "incognito": (.value.incognito // "allowed")
            }
          }
        ) | from_entries
      )
    }
  ')

  # Validate extension ID formats
  for ext_id in $(echo "$EXTENSIONS" | jq -r 'keys[]'); do
    if ! echo "$ext_id" | grep -qE '^[a-z]{32}$'; then
      echo "========================================================================"
      echo "WARNING: Extension ID '$ext_id' does not match expected format"
      echo "  Expected: 32 lowercase letters (e.g. fcoeoabgfenejglbffodgkkbkcdhcgfn)"
      echo "  Got:      '$ext_id'"
      echo "  This may be valid for enterprise or custom extensions."
      echo "========================================================================"
    fi
  done

  # Write Chrome managed policy
  mkdir -p /etc/opt/chrome/policies/managed
  echo "$POLICY_JSON" > /etc/opt/chrome/policies/managed/extension_settings.json
  echo "Chrome extension policy written to /etc/opt/chrome/policies/managed/extension_settings.json"

  # Copy to Chromium policy directory for compatibility
  mkdir -p /etc/chromium/policies/managed
  cp /etc/opt/chrome/policies/managed/extension_settings.json /etc/chromium/policies/managed/extension_settings.json
  echo "Chromium extension policy written to /etc/chromium/policies/managed/extension_settings.json"
fi

# =============================================================================
# Section 4: Wrapper Script
# =============================================================================

echo "Creating Chrome wrapper script at /usr/local/bin/chrome..."

cat > /usr/local/bin/chrome << 'EOF'
#!/bin/bash

# Wrapper script to run Chrome in a container environment
# addressing sandbox and display issues

# Source runtime config
if [ -f /etc/chrome-wrapper/config ]; then
  source /etc/chrome-wrapper/config
fi

# Defaults if config is missing
CHROME_BINARY="${CHROME_BINARY:-google-chrome-stable}"
DISPLAY_MODE="${DISPLAY_MODE:-headless}"
SCREEN_RESOLUTION="${SCREEN_RESOLUTION:-1920x1080x24}"

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
log "Display mode: $DISPLAY_MODE"

# Virtual display management
XVFB_DISPLAY=":99"
XVFB_PIDFILE="/tmp/.xvfb-display99.pid"
XVFB_LOCKFILE="/tmp/.X99-lock"

is_xvfb_running() {
  if [ -f "$XVFB_PIDFILE" ]; then
    local pid
    pid=$(cat "$XVFB_PIDFILE" 2>/dev/null)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
    rm -f "$XVFB_PIDFILE"
  fi
  if [ -f "$XVFB_LOCKFILE" ]; then
    local pid
    pid=$(cat "$XVFB_LOCKFILE" 2>/dev/null | tr -d ' ')
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
    rm -f "$XVFB_LOCKFILE"
  fi
  return 1
}

start_xvfb() {
  log "Starting Xvfb on display $XVFB_DISPLAY with resolution $SCREEN_RESOLUTION"
  Xvfb "$XVFB_DISPLAY" -screen 0 "$SCREEN_RESOLUTION" -ac +extension GLX +render -noreset &
  local xvfb_pid=$!
  echo "$xvfb_pid" > "$XVFB_PIDFILE"
  local wait_count=0
  while [ $wait_count -lt 10 ]; do
    if [ -f "$XVFB_LOCKFILE" ]; then
      log "Xvfb started successfully (PID: $xvfb_pid)"
      return 0
    fi
    sleep 0.1
    wait_count=$((wait_count + 1))
  done
  if kill -0 "$xvfb_pid" 2>/dev/null; then
    log "Xvfb running (PID: $xvfb_pid)"
    return 0
  fi
  log "WARNING: Xvfb failed to start"
  rm -f "$XVFB_PIDFILE"
  return 1
}

# Display setup based on DISPLAY_MODE
case "$DISPLAY_MODE" in
  xvfb)
    if [ -z "$DISPLAY" ]; then
      if command -v Xvfb >/dev/null 2>&1; then
        if is_xvfb_running; then
          log "Reusing existing Xvfb on $XVFB_DISPLAY"
          export DISPLAY="$XVFB_DISPLAY"
        elif start_xvfb; then
          export DISPLAY="$XVFB_DISPLAY"
        else
          log "Xvfb failed, falling back to headless mode"
        fi
      else
        log "Xvfb not available, falling back to headless mode"
      fi
    else
      log "Using existing DISPLAY=$DISPLAY"
    fi
    ;;
  vnc)
    # VNC mode: desktop-lite sets DISPLAY=:1
    if [ -n "$DISPLAY" ]; then
      log "VNC mode: using existing DISPLAY=$DISPLAY (set by desktop-lite)"
      # Configure cursor theme for VNC display
      export XCURSOR_THEME="${XCURSOR_THEME:-Adwaita}"
      export XCURSOR_SIZE="${XCURSOR_SIZE:-24}"
      # Initialize root window cursor so VNC server has a cursor to broadcast
      if command -v xsetroot >/dev/null 2>&1; then
        xsetroot -cursor_name left_ptr 2>/dev/null || true
      fi
    else
      log "WARNING: VNC mode but no DISPLAY set. Is desktop-lite running?"
      log "Falling back to headless mode"
    fi
    # Start VNC clipboard daemons if clipboard support was installed
    if [ "$VNC_CLIPBOARD" = "true" ] && [ -n "$DISPLAY" ]; then
      # vncconfig: bridges VNC protocol clipboard with X11 cutbuffer
      if command -v vncconfig >/dev/null 2>&1 && ! pgrep -x vncconfig >/dev/null 2>&1; then
        vncconfig -nowin &
        log "Started vncconfig for VNC clipboard support (PID: $!)"
      fi
      # autocutsel: syncs X11 CLIPBOARD selection with cutbuffer
      if command -v autocutsel >/dev/null 2>&1; then
        if ! pgrep -f "autocutsel.*CLIPBOARD" >/dev/null 2>&1; then
          autocutsel -selection CLIPBOARD -fork
          log "Started autocutsel for CLIPBOARD selection sync"
        fi
        if ! pgrep -f "autocutsel.*PRIMARY" >/dev/null 2>&1; then
          autocutsel -selection PRIMARY -fork
          log "Started autocutsel for PRIMARY selection sync"
        fi
      fi
    fi
    ;;
  headless|*)
    # Headless mode: no display needed
    log "Headless mode: skipping display setup"
    ;;
esac

# Create empty .Xauthority file if it doesn't exist
if [ ! -f ~/.Xauthority ]; then
  touch ~/.Xauthority
fi

# Disable DBus for Chrome to reduce error messages
export DBUS_SESSION_BUS_ADDRESS="disabled:"

# Add --no-sandbox only when running as root (uid 0).
# Chrome's sandbox works for non-root users; the flag triggers a warning bar.
if [ "$(id -u)" -eq 0 ] && [[ "$*" != *"--no-sandbox"* ]]; then
  log "Running as root (uid 0), adding --no-sandbox flag"
  set -- --no-sandbox "$@"
fi

# Add locale flag if configured and not already in args
if [ -n "$LOCALE" ] && [[ "$*" != *"--lang="* ]]; then
  set -- --lang="$LOCALE" "$@"
fi

# Add debugging port if configured and not already in args
if [ -n "$DEBUGGING_PORT" ] && [[ "$*" != *"--remote-debugging-port"* ]]; then
  set -- --remote-debugging-port="$DEBUGGING_PORT" "$@"
fi

# Add extra flags from config
if [ -n "$EXTRA_FLAGS" ]; then
  # shellcheck disable=SC2086
  set -- $EXTRA_FLAGS "$@"
fi

# Detect if a real desktop environment is available (e.g., desktop-lite VNC)
has_real_desktop() {
  # If DISPLAY is the Xvfb virtual display we manage, it's not a real desktop
  if [ "$DISPLAY" = "$XVFB_DISPLAY" ]; then
    return 1
  fi
  # Check if a display is set and accessible
  if [ -n "$DISPLAY" ] && command -v xdpyinfo >/dev/null 2>&1 && xdpyinfo >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

# Check if this is being called from browser_action
if [[ "$*" == *"--remote-debugging-port"* ]]; then
  # Running in Puppeteer/browser_action mode - keep remote debugging output visible
  stderr_log=$(mktemp)

  # Run Chrome and capture stderr to a temp file for reliable exit code
  "$CHROME_BINARY" \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-features=VizDisplayCompositor \
    "$@" 2>"$stderr_log"

  exit_code=$?

  # Replay stderr so callers can see it, then log
  if [ -s "$stderr_log" ]; then
    cat "$stderr_log" >&2
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

  # Determine extensions flag: disable extensions unless managed policy files exist
  EXTENSIONS_FLAG="--disable-extensions"
  BACKGROUND_NETWORKING_FLAG="--disable-background-networking"
  if [ -d /etc/opt/chrome/policies/managed ] && ls /etc/opt/chrome/policies/managed/*.json >/dev/null 2>&1; then
    EXTENSIONS_FLAG=""
    BACKGROUND_NETWORKING_FLAG=""
    log "Extension policies detected, extensions and background networking enabled"
  fi

  # Determine if user explicitly passed a --headless variant
  USER_WANTS_HEADLESS=false
  HEADLESS_FLAG="--headless=new"
  if [[ "$*" == *"--headless"* ]]; then
    USER_WANTS_HEADLESS=true
    # User already passed their own --headless flag, don't add another
    HEADLESS_FLAG=""
  fi

  # Choose GUI or headless mode based on desktop environment availability and display mode
  if [ "$USER_WANTS_HEADLESS" = false ] && { [ "$DISPLAY_MODE" = "vnc" ] || [ "$DISPLAY_MODE" = "xvfb" ]; } && has_real_desktop; then
    log "Real desktop detected (DISPLAY=$DISPLAY), launching in GUI mode"
    log "Final command: $CHROME_BINARY --disable-dev-shm-usage --no-first-run --no-default-browser-check --disable-features=VizDisplayCompositor ${EXTENSIONS_FLAG} ${BACKGROUND_NETWORKING_FLAG} --disable-sync --disable-translate --mute-audio --disable-dbus $*"

    # GUI mode: launch Chrome with a visible window on the real desktop
    "$CHROME_BINARY" \
      --disable-dev-shm-usage \
      --no-first-run \
      --no-default-browser-check \
      --disable-features=VizDisplayCompositor \
      ${EXTENSIONS_FLAG:+$EXTENSIONS_FLAG} \
      ${BACKGROUND_NETWORKING_FLAG:+$BACKGROUND_NETWORKING_FLAG} \
      --disable-sync \
      --disable-translate \
      --mute-audio \
      --disable-dbus \
      "$@" 2>"$local_stderr_file"
  else
    log "Launching in headless mode"
    log "Final command: $CHROME_BINARY --disable-dev-shm-usage --disable-gpu --disable-software-rasterizer --no-first-run --no-default-browser-check --no-zygote --disable-features=VizDisplayCompositor ${EXTENSIONS_FLAG} ${BACKGROUND_NETWORKING_FLAG} --disable-sync --disable-translate --hide-scrollbars --metrics-recording-only --mute-audio --disable-dbus ${HEADLESS_FLAG} $*"

    # Headless mode: no visible window
    "$CHROME_BINARY" \
      --disable-dev-shm-usage \
      --disable-gpu \
      --disable-software-rasterizer \
      --no-first-run \
      --no-default-browser-check \
      --no-zygote \
      --disable-features=VizDisplayCompositor \
      ${EXTENSIONS_FLAG:+$EXTENSIONS_FLAG} \
      ${BACKGROUND_NETWORKING_FLAG:+$BACKGROUND_NETWORKING_FLAG} \
      --disable-sync \
      --disable-translate \
      --hide-scrollbars \
      --metrics-recording-only \
      --mute-audio \
      --disable-dbus \
      ${HEADLESS_FLAG:+$HEADLESS_FLAG} \
      "$@" 2>"$local_stderr_file"
  fi

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

# =============================================================================
# Section 5: Embedded Documentation
# =============================================================================

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

### Interactive Mode

#### Xvfb (Virtual Framebuffer)
With `displayMode: "xvfb"`, Chrome runs on a virtual display `:99`. Useful for
automated testing that requires a display server.

#### VNC (Browser-Based Viewing)
With `displayMode: "vnc"` and the `desktop-lite` feature, Chrome runs in a
full desktop environment accessible via:
- noVNC (browser): http://localhost:6080
- VNC client: port 5901

Clipboard sharing between host and Chrome is enabled automatically via
vncconfig and autocutsel. In noVNC, use the clipboard panel in the sidebar.

## Technical Details

The wrapper script applies the following configurations to Chrome:
- Automatically adds --no-sandbox when running as root (uid 0) for container compatibility
- Sources runtime config from /etc/chrome-wrapper/config
- Handles display setup based on configured display mode
- Supports channel selection (stable, beta, dev)
- Logs command arguments, errors, and exit codes to a log file

### Configuration

Runtime configuration is stored at `/etc/chrome-wrapper/config` and includes:
- CHROME_BINARY: Which Chrome binary to use
- DISPLAY_MODE: headless, xvfb, or vnc
- SCREEN_RESOLUTION: Virtual display resolution
- DEBUGGING_PORT: Remote debugging port
- EXTRA_FLAGS: Additional Chrome flags
- LOCALE: Chrome UI locale

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

echo "Google Chrome (${CHANNEL}) installation and configuration complete."
echo "Display mode: ${DISPLAYMODE:-headless}"
