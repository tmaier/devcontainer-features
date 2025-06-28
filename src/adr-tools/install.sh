#!/bin/sh
set -e

# Install adr-tools
curl -L https://github.com/npryce/adr-tools/archive/refs/tags/3.0.0.tar.gz --output /tmp/adr-tools.tar.gz
sudo tar -C /usr/local/bin -xzf /tmp/adr-tools.tar.gz adr-tools-3.0.0/src
rm /tmp/adr-tools.tar.gz
