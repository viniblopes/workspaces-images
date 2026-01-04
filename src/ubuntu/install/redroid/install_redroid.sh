#!/usr/bin/env bash
set -ex

# Redroid installation - ENHANCED but COMPATIBLE with Kasm's implementation
# This script EXTENDS the original Kasm Redroid setup with additional Android SDK tools
ARCH=$(arch | sed 's/x86_64/amd64/g')

# Install base dependencies (same as original Kasm script)
apt-get update
apt-get install -y \
  android-tools-adb \
  android-tools-fastboot \
  ffmpeg \
  libsdl2-2.0-0 \
  adb \
  wget \
  gcc \
  git \
  pkg-config \
  meson \
  ninja-build \
  libsdl2-dev \
  libavcodec-dev \
  libavdevice-dev \
  libavformat-dev \
  libavutil-dev \
  libswresample-dev \
  libusb-1.0-0 \
  libusb-1.0-0-dev \
  jq

# Install scrcpy (same as original)
mkdir -p /opt/
cd /opt/
if [ ! -d "/opt/scrcpy" ]; then
  git clone https://github.com/Genymobile/scrcpy
  cd scrcpy
  ./install_release.sh
fi

# ===== ENHANCEMENTS BELOW - Additional Android SDK tools for Flutter development =====

# Set up Android SDK environment variables (for Flutter/Android development)
cat > /etc/profile.d/android.sh <<EOL
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH
EOL

chmod +x /etc/profile.d/android.sh

# Create Android SDK directory structure
mkdir -p /opt/android-sdk/cmdline-tools
chown -R 1000:1000 /opt/android-sdk

# Download Android command line tools (for Flutter doctor and SDK management)
cd /tmp
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
wget -q "$CMDLINE_TOOLS_URL" -O commandlinetools.zip
unzip -q commandlinetools.zip -d /opt/android-sdk/cmdline-tools
mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest
rm commandlinetools.zip

# Set ownership
chown -R 1000:1000 /opt/android-sdk

# Install essential SDK packages (needed for Flutter)
export ANDROID_HOME=/opt/android-sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH

# Accept licenses and install platform tools
yes | sudo -u "#1000" bash -c "export ANDROID_HOME=/opt/android-sdk && export PATH=/opt/android-sdk/cmdline-tools/latest/bin:\$PATH && sdkmanager --licenses" || true
sudo -u "#1000" bash -c "export ANDROID_HOME=/opt/android-sdk && export PATH=/opt/android-sdk/cmdline-tools/latest/bin:\$PATH && sdkmanager 'platform-tools' 'platforms;android-34' 'build-tools;34.0.0'" || true

# Create desktop launcher for scrcpy (additional convenience)
cat > /usr/share/applications/scrcpy.desktop <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=scrcpy (Screen Mirror)
Comment=Mirror Android screen via scrcpy
Exec=bash -c "scrcpy --serial localhost:5555"
Icon=phone
Categories=Development;Utility;
Terminal=false
EOL

chmod +x /usr/share/applications/scrcpy.desktop

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