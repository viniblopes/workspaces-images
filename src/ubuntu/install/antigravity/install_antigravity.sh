#!/usr/bin/env bash
set -ex

# Install Antigravity IDE from Google's APT repository
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

# Create keyrings directory
mkdir -p /etc/apt/keyrings

# Add Google's GPG key
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
  gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg

# Add Antigravity repository
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
  tee /etc/apt/sources.list.d/antigravity.list > /dev/null

# Update package cache and install
apt-get update
apt-get install -y antigravity

# Create desktop icon if .desktop file exists
if [ -f /usr/share/applications/antigravity.desktop ]; then
  cp /usr/share/applications/antigravity.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/antigravity.desktop
  chown 1000:1000 $HOME/Desktop/antigravity.desktop
else
  # Create custom desktop entry if not provided by package
  cat > /usr/share/applications/antigravity.desktop <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE
Comment=Antigravity IDE by Google
Exec=antigravity
Icon=antigravity
Categories=Development;IDE;
Terminal=false
StartupNotify=true
EOL
  chmod +x /usr/share/applications/antigravity.desktop
  cp /usr/share/applications/antigravity.desktop $HOME/Desktop/antigravity.desktop
  chmod +x $HOME/Desktop/antigravity.desktop
  chown 1000:1000 $HOME/Desktop/antigravity.desktop
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
