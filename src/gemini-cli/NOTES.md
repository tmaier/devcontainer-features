# Gemini CLI Feature

This feature installs [Gemini CLI](https://github.com/google-gemini/gemini-cli), Google's official CLI for AI-powered development assistance using Gemini models.

## Requirements

- Node.js

## Manual config for `devcontainer.json`

Mount the local `~/.gemini/` directory into the Dev Container.
Add the following mount to the `devcontainer.json` file.
Replace `vscode` with the actual name of your user (see `remoteUser` property)

```json
  "mounts": [
    {
      "source": "${localEnv:HOME}/.gemini",
      "target": "/home/vscode/.gemini",
      "type": "bind"
    }
  ],
```

## Usage

After installation, run `gemini` in your project directory to get started.

You'll need to authenticate with Google AI Studio to access the Gemini API.

For detailed documentation, see the [Gemini CLI documentation](https://github.com/google-gemini/gemini-cli).