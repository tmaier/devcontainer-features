## What This Feature Installs

This feature installs [ImageMagick](https://imagemagick.org/), a powerful image processing and manipulation library, along with Ghostscript for enhanced PDF support in container environments.

## Version Support

This feature supports both **ImageMagick 6** and **ImageMagick 7**. The installation script automatically detects which version is installed and configures the appropriate policy file:
- ImageMagick 6: `/etc/ImageMagick-6/policy.xml`
- ImageMagick 7: `/etc/ImageMagick-7/policy.xml`

If both versions are present, both policy files will be configured. If neither policy file exists after installation, a warning will be logged, but the feature installation will continue successfully.

## Key Configuration

**PDF Processing Support**: The feature automatically configures ImageMagick to process PDF files by modifying the security policy, enabling PDF manipulation operations which are often restricted by default.

## Documentation

For complete usage instructions and documentation, visit the official ImageMagick website: https://imagemagick.org/