#!/bin/sh
set -e

apt-get update -y
apt-get -y install --no-install-recommends ghostscript imagemagick
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*

# Enables ImageMagick to process PDF files
# Ref. https://askubuntu.com/a/1181773
# Support both ImageMagick 6 and ImageMagick 7 policy paths
policy_updated=false

if [ -f /etc/ImageMagick-6/policy.xml ]; then
    echo "Updating ImageMagick 6 policy.xml to enable PDF processing..."
    sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml
    policy_updated=true
fi

if [ -f /etc/ImageMagick-7/policy.xml ]; then
    echo "Updating ImageMagick 7 policy.xml to enable PDF processing..."
    sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml
    policy_updated=true
fi

if [ "$policy_updated" = false ]; then
    echo "Warning: No ImageMagick policy.xml file found at /etc/ImageMagick-6/policy.xml or /etc/ImageMagick-7/policy.xml"
    echo "PDF processing permissions were not configured. This may limit ImageMagick's ability to process PDF files."
fi
