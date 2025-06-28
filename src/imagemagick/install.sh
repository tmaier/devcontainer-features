#!/bin/sh
set -e

apt-get update -y
apt-get -y install --no-install-recommends ghostscript imagemagick
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*

# Enables ImageMagic to process PDF files
# Ref. https://askubuntu.com/a/1181773
sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml
