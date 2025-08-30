# Codex CLI Feature

This feature installs [Codex CLI](https://github.com/openai/codex), OpenAI's local coding agent for AI-powered development assistance.

## Requirements

- Node.js

## Manual config for `devcontainer.json`

Mount the local `~/.codex/` directory into the Dev Container.
Add the following mount to the `devcontainer.json` file.
Replace `vscode` with the actual name of your user (see `remoteUser` property)

```json
  "mounts": [
    {
      "source": "${localEnv:HOME}/.codex",
      "target": "/home/vscode/.codex",
      "type": "bind"
    }
  ],
```

## Usage

After installation, run `codex` in your project directory to get started.

You'll need to sign in with a ChatGPT account (Plus, Pro, Team, Edu, or Enterprise plans recommended for best experience).

For detailed documentation, see the [Codex CLI documentation](https://github.com/openai/codex).