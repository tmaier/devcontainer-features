
# imagemagick (imagemagick)

Installs imagemagick

## Example Usage

```json
"features": {
    "ghcr.io/tmaier/devcontainer-features/imagemagick:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## What This Feature Installs

This feature installs [ImageMagick](https://imagemagick.org/), a powerful image processing and manipulation library, along with Ghostscript for enhanced PDF support in container environments.

**Supported Versions**: This feature supports both ImageMagick 6 and ImageMagick 7, automatically detecting and configuring the installed version.

## Key Configuration

**PDF Processing Support**: The feature automatically configures ImageMagick to process PDF files by modifying the security policy, enabling PDF manipulation operations which are often restricted by default.

## Documentation

For complete usage instructions and documentation, visit the official ImageMagick website: https://imagemagick.org/

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/tmaier/devcontainer-features/blob/main/src/imagemagick/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
