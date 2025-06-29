# Claude Code Feature

This feature installs [Claude Code](https://www.anthropic.com/claude-code), Anthropic's official CLI for AI-powered development assistance.

It also mounts the `~/.claude/` folder of the host system to the devcontainer to provide shared settings and memory (`CLAUDE.md`).

## Requirements

- Node.js

## Options

- `remoteUser` (string, default: "vscode"): The remote user that will be used in the container. Must match the remoteUser setting in your devcontainer.json.

## Usage

After installation, run `claude` in your project directory to get started.

For detailed documentation, see the [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/overview).
