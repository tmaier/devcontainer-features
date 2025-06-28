#!/bin/sh
set -e

# Install mc
sudo curl https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o /usr/bin/mc
sudo chmod +x /usr/bin/mc
