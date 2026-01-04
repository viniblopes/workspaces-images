#!/usr/bin/env bash
set -ex

# Install DBeaver Community Edition
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

# Install dependencies
apt-get update
apt-get install -y wget ca-certificates

# Download and install DBeaver
# Get latest version from GitHub releases
DBEAVER_VERSION=$(curl -s https://api.github.com/repos/dbeaver/dbeaver/releases/latest | grep -Po '"tag_name": "\K[0-9.]+')
if [ -z "$DBEAVER_VERSION" ]; then
  # Fallback to a known stable version if API fails
  DBEAVER_VERSION="23.3.0"
fi

wget -q "https://github.com/dbeaver/dbeaver/releases/download/${DBEAVER_VERSION}/dbeaver-ce_${DBEAVER_VERSION}_${ARCH}.deb" -O dbeaver.deb

# Install the package
apt-get install -y ./dbeaver.deb
rm dbeaver.deb

# Desktop icon
if [ -f /usr/share/applications/dbeaver.desktop ]; then
  cp /usr/share/applications/dbeaver.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/dbeaver.desktop
  chown 1000:1000 $HOME/Desktop/dbeaver.desktop
fi

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi
