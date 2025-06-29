# Dev Container Features Collection

A collection of custom [Dev Container Features](https://containers.dev/implementors/features/) for enhancing development containers with additional tools and utilities.

## Available Features

| Feature | Description | Repository |
|---------|-------------|------------|
| [adr-tools](https://github.com/tmaier/devcontainer-features/tree/main/src/adr-tools) | Architecture Decision Records management tools | `ghcr.io/tmaier/devcontainer-features/adr-tools` |
| [chrome](https://github.com/tmaier/devcontainer-features/tree/main/src/chrome) | Google Chrome with container-optimized wrapper script | `ghcr.io/tmaier/devcontainer-features/chrome` |
| [imagemagick](https://github.com/tmaier/devcontainer-features/tree/main/src/imagemagick) | ImageMagick image processing library with PDF support | `ghcr.io/tmaier/devcontainer-features/imagemagick` |
| [mc](https://github.com/tmaier/devcontainer-features/tree/main/src/mc) | MinIO Client for object storage operations | `ghcr.io/tmaier/devcontainer-features/mc` |
| [yek](https://github.com/tmaier/devcontainer-features/tree/main/src/yek) | Repository file serialization tool for LLM consumption | `ghcr.io/tmaier/devcontainer-features/yek` |
| [yq](https://github.com/tmaier/devcontainer-features/tree/main/src/yq) | YAML, JSON, XML, and CSV processor | `ghcr.io/tmaier/devcontainer-features/yq` |

## Usage

Add features to your `devcontainer.json`:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/tmaier/devcontainer-features/chrome:1": {},
        "ghcr.io/tmaier/devcontainer-features/yq:1": {},
        "ghcr.io/tmaier/devcontainer-features/imagemagick:1": {}
    }
}
```

## Links

- [Latest releases of the features on GitHub](https://github.com/tmaier?tab=packages&repo_name=devcontainer-features)
- [Dev Container Features specification](https://containers.dev/implementors/features/)
