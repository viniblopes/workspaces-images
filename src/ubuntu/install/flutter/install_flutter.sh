#!/usr/bin/env bash
set -ex

# Install Flutter SDK
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/x64/g')

# Install dependencies
apt-get update
apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  libgtk-3-dev \
  liblzma-dev \
  libstdc++-12-dev

# Download Flutter SDK using Git (works for all architectures)
mkdir -p /opt/flutter
cd /opt/flutter

# Clone Flutter stable branch
# This method works for both x64 and ARM64 as Flutter will download the correct binaries
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Set ownership
chown -R 1000:1000 /opt/flutter

# Add Flutter to PATH for all users
cat > /etc/profile.d/flutter.sh <<EOL
export FLUTTER_HOME=/opt/flutter/flutter
export PATH=\$FLUTTER_HOME/bin:\$PATH
export CHROME_EXECUTABLE=/usr/bin/google-chrome
EOL

# Make it executable
chmod +x /etc/profile.d/flutter.sh

# Source it for current session
export FLUTTER_HOME=/opt/flutter/flutter
export PATH=$FLUTTER_HOME/bin:$PATH
export CHROME_EXECUTABLE=/usr/bin/google-chrome

# Pre-download Flutter artifacts and accept licenses
cd /opt/flutter/flutter
sudo -u "#1000" bash -c "export PATH=/opt/flutter/flutter/bin:\$PATH && flutter precache"
sudo -u "#1000" bash -c "export PATH=/opt/flutter/flutter/bin:\$PATH && flutter config --no-analytics"
sudo -u "#1000" bash -c "export PATH=/opt/flutter/flutter/bin:\$PATH && yes | flutter doctor --android-licenses" || true

# Create desktop shortcut for Flutter doctor
cat > /usr/share/applications/flutter-doctor.desktop <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Flutter Doctor
Comment=Check Flutter installation
Exec=x-terminal-emulator -e "bash -c 'flutter doctor -v; read -p \"Press Enter to close...\"'"
Icon=utilities-terminal
Categories=Development;
Terminal=false
EOL

chmod +x /usr/share/applications/flutter-doctor.desktop

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
