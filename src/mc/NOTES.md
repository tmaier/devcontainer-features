## What This Feature Installs

This feature installs the MinIO Client (`mc`), a command-line tool for interacting with MinIO and Amazon S3 compatible object storage services.

Upstream publishes no free `mc` binaries, so the feature installs the [pgsty/mc](https://github.com/pgsty/mc) community fork, pinned to one release and verified by SHA-256, for `amd64` and `arm64`. The fork names its binary `mcli`; the feature installs it as `mc`.

## Upgrading the pinned release

Copy the new `TAG`, `VERSION` and both linux checksums in `install.sh` from the release's `mcli_<version>_checksums.txt`, then bump the feature version.

## Documentation

For usage instructions, see the [pgsty/mc repository](https://github.com/pgsty/mc).
