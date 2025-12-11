#!/bin/sh
set -e

apt-get update -y
apt-get -y install --no-install-recommends ghostscript imagemagick
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*

# Enables ImageMagick to process PDF files
# Ref. https://askubuntu.com/a/1181773
# Supports both ImageMagick 6 and 7
if [ -f /etc/ImageMagick-6/policy.xml ]; then
    sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml
elif [ -f /etc/ImageMagick-7/policy.xml ]; then
    sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml
fi
