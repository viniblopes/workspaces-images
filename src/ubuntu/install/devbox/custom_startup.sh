#!/usr/bin/env bash
set -e

# Custom startup script for devbox image
# This script sources environment variables and then calls the DinD startup

echo "Starting devbox initialization..."

# Source environment variables for development tools
if [ -f /etc/profile.d/flutter.sh ]; then
  source /etc/profile.d/flutter.sh
fi

if [ -f /etc/profile.d/fvm.sh ]; then
  source /etc/profile.d/fvm.sh
fi

if [ -f /etc/profile.d/android.sh ]; then
  source /etc/profile.d/android.sh
fi

# Create workspace directories
mkdir -p $HOME/workspace
mkdir -p $HOME/.android
mkdir -p $HOME/.fvm

# Set proper permissions
chown -R 1000:1000 $HOME/workspace 2>/dev/null || true
chown -R 1000:1000 $HOME/.android 2>/dev/null || true
chown -R 1000:1000 $HOME/.fvm 2>/dev/null || true

# Display environment info
echo "==================================="
echo "Development Environment Ready!"
echo "==================================="
echo "Flutter: $(which flutter 2>/dev/null || echo 'Restart terminal to use')"
echo "Android SDK: ${ANDROID_HOME:-Not set}"
echo "==================================="

# Call the DinD custom startup (which handles Docker daemon)
if [ -f /dockerstartup/install/dind/custom_startup.sh ]; then
  source /dockerstartup/install/dind/custom_startup.sh
else
  # Fallback to default startup
  exec "$@"
fi
