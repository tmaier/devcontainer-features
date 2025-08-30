# Codex CLI (codex)

Installs OpenAI Codex CLI for local AI-powered coding assistance

## Example Usage

```json
"features": {
    "ghcr.io/tmaier/devcontainer-features/codex:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Customizations

### VS Code Extensions

- `openai.chatgpt`

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/tmaier/devcontainer-features/blob/main/src/codex/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._