#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing Codex CLI..."

# Install Node.js if not available
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js 22.x..."
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y --no-install-recommends nodejs
    rm -rf /var/lib/apt/lists/*
fi

# Check Node.js version (requires 18+)
NODE_VERSION=$(node --version | sed 's/v//')
MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1)

if [ "$MAJOR_VERSION" -lt 18 ]; then
    echo "Error: Node.js 18+ is required, but found version $NODE_VERSION"
    exit 1
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "Error: npm is required but not found."
    exit 1
fi

# Install Codex CLI globally (runs as root during container build)
echo "Installing Codex CLI globally..."
npm install -g @openai/codex

# Verify installation
if ! command -v codex &> /dev/null; then
    echo "Error: Codex CLI installation failed"
    exit 1
fi

echo "Codex CLI installed successfully!"