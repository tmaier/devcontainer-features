#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing Claude Code..."

# Ensure curl and other dependencies are available
if ! command -v curl &> /dev/null; then
    echo "curl not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update -y && apt-get install -y --no-install-recommends curl ca-certificates
        rm -rf /var/lib/apt/lists/*
    elif command -v apk &> /dev/null; then
        apk add --no-cache curl ca-certificates
    elif command -v yum &> /dev/null; then
        yum install -y curl ca-certificates
    else
        echo "Error: curl is required but could not be installed automatically."
        exit 1
    fi
fi

# Ensure tar and gzip are available (needed by the installer)
if ! command -v tar &> /dev/null || ! command -v gzip &> /dev/null; then
    echo "Installing archive utilities..."
    apt-get update -y
    apt-get install -y --no-install-recommends tar gzip
    rm -rf /var/lib/apt/lists/*
fi

# Determine version argument for the installer
INSTALL_ARGS=""
if [ -n "$VERSION" ] && [ "$VERSION" != "latest" ]; then
    INSTALL_ARGS="$VERSION"
fi

# Install Claude Code using the native installer
# See https://code.claude.com/docs/en/setup
if [ -n "$_REMOTE_USER" ] && [ "$_REMOTE_USER" != "root" ]; then
    echo "Installing Claude Code for user: $_REMOTE_USER"
    su "$_REMOTE_USER" -c "curl -fsSL https://claude.ai/install.sh | bash -s $INSTALL_ARGS"
    INSTALL_HOME="$_REMOTE_USER_HOME"
else
    echo "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash -s $INSTALL_ARGS
    INSTALL_HOME="${HOME:-/root}"
fi

# Ensure claude is on PATH for all users by symlinking to /usr/local/bin
# The native installer places the binary at ~/.local/bin/claude
if [ -f "$INSTALL_HOME/.local/bin/claude" ] && [ ! -f /usr/local/bin/claude ]; then
    ln -s "$INSTALL_HOME/.local/bin/claude" /usr/local/bin/claude
    echo "Symlinked claude to /usr/local/bin/claude"
fi

# Set up yolo alias if requested
if [ "${YOLOALIAS:-false}" = "true" ]; then
    echo "Setting up 'yolo' alias..."
    ALIAS_CMD='alias yolo="claude --allow-dangerously-skip-permissions"'
    TARGET_HOME="${INSTALL_HOME}"

    add_shell_alias_if_missing() {
        local rc_file="$1"
        local alias_name="$2"
        local alias_cmd="$3"

        if [ -f "$rc_file" ] && grep -Eq "^[[:space:]]*alias[[:space:]]+${alias_name}=" "$rc_file"; then
            echo "Skipping $rc_file: alias '$alias_name' already exists."
            return 0
        fi

        touch "$rc_file"
        printf '%s\n' "$alias_cmd" >> "$rc_file"
    }

    # bash
    add_shell_alias_if_missing "$TARGET_HOME/.bashrc" "yolo" "$ALIAS_CMD"

    # zsh
    add_shell_alias_if_missing "$TARGET_HOME/.zshrc" "yolo" "$ALIAS_CMD"

    # fish — create a function file (idiomatic for fish)
    FISH_FUNC_DIR="$TARGET_HOME/.config/fish/functions"
    FISH_FUNC_FILE="$FISH_FUNC_DIR/yolo.fish"
    if [ -f "$FISH_FUNC_FILE" ]; then
        echo "Skipping $FISH_FUNC_FILE: function already exists."
    else
        mkdir -p "$FISH_FUNC_DIR"
        cat > "$FISH_FUNC_FILE" << 'FISHEOF'
function yolo --description "claude --allow-dangerously-skip-permissions"
    claude --allow-dangerously-skip-permissions $argv
end
FISHEOF
    fi

    # Fix ownership if installing for non-root user
    if [ -n "$_REMOTE_USER" ] && [ "$_REMOTE_USER" != "root" ]; then
        chown "$_REMOTE_USER" "$TARGET_HOME/.bashrc" "$TARGET_HOME/.zshrc"
        chown "$_REMOTE_USER" "$FISH_FUNC_FILE"
    fi

    echo "yolo alias configured for bash, zsh, and fish."
fi

echo "Claude Code installed successfully!"
