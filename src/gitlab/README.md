
# GitLab CLI & Workflow (gitlab)

Installs glab CLI and GitLab Workflow VS Code extension for GitLab integration

## Example Usage

```json
"features": {
    "ghcr.io/iot-rocket/devcontainer-features/gitlab:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Customizations

### VS Code Extensions

- `GitLab.gitlab-workflow`

## What This Feature Installs

1. **glab CLI** - The official GitLab command-line tool (latest version)
2. **GitLab Workflow VS Code extension** - GitLab integration for VS Code (`GitLab.gitlab-workflow`)

## Authentication

After the container starts, authenticate with your GitLab instance:

```bash
# Interactive login (gitlab.com)
glab auth login

# Login to a self-hosted instance
glab auth login --hostname gitlab.example.com
```

## Basic Usage

```bash
# Clone a repository
glab repo clone owner/repo

# Create a merge request
glab mr create --fill

# List open issues
glab issue list

# View CI/CD pipeline status
glab ci status

# Browse the repository in the browser
glab repo view --web
```

## Further Reading

- [glab CLI documentation](https://gitlab.com/gitlab-org/cli/-/blob/main/README.md)
- [GitLab Workflow VS Code extension](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow)


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/iot-rocket/devcontainer-features/blob/main/src/gitlab/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
