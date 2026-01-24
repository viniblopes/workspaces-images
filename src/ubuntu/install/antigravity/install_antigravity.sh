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

# Update package cache and install (with retry for mirror sync issues)
apt-get update --allow-releaseinfo-change || apt-get update || true
apt-get install -y antigravity

# Create wrapper script FIRST, before modifying desktop entries
cat > /usr/local/bin/antigravity-wrapper <<'EOL'
#!/bin/bash
# Disable core dumps for this session (soft and hard limits)
ulimit -S -c 0
ulimit -H -c 0 2>/dev/null || true

# Environment variables to disable Electron/Chromium crash reporting
export ELECTRON_DISABLE_CRASH_REPORTER=1
export CHROME_CRASHPAD_PIPE_NAME=/dev/null
export BREAKPAD_DUMP_LOCATION=/dev/null

# Launch Antigravity with comprehensive flags for container compatibility and crash prevention
# Container compatibility:
# --no-sandbox: Required in containers (no setuid sandbox available)
# --disable-setuid-sandbox: Required in containers
# --disable-gpu: Prevents GPU-related crashes in virtualized environments
# --disable-dev-shm-usage: Avoids /dev/shm size limitations in containers
#
# Crash prevention:
# --disable-crash-reporter: Disables Chromium crash reporter
# --disable-breakpad: Disables Breakpad crash reporting system
# --no-crash-upload: Prevents crash upload attempts
# --crash-dumps-dir=/dev/null: Redirects any crash dumps to /dev/null
# --disable-component-update: Prevents component updates that may crash
# --disable-background-networking: Reduces background processes
# --disable-sync: Disables sync that can cause crashes
exec /usr/share/antigravity/antigravity \
  --no-sandbox \
  --disable-setuid-sandbox \
  --disable-gpu \
  --disable-dev-shm-usage \
  --disable-crash-reporter \
  --disable-breakpad \
  --no-crash-upload \
  --crash-dumps-dir=/dev/null \
  --disable-component-update \
  --disable-background-networking \
  --disable-sync \
  "$@"
EOL

chmod +x /usr/local/bin/antigravity-wrapper

# CRITICAL: Move original binary and replace with wrapper
# This ensures ALL ways of launching Antigravity use our protections
if [ -f /usr/share/antigravity/antigravity ] && [ ! -f /usr/share/antigravity/antigravity.bin ]; then
  echo "Moving original Antigravity binary to antigravity.bin..."
  mv /usr/share/antigravity/antigravity /usr/share/antigravity/antigravity.bin
fi

# Create wrapper at the original binary location
cat > /usr/share/antigravity/antigravity <<'EOL'
#!/bin/bash
# Antigravity wrapper - ensures crash prevention for all launch methods
# Disable core dumps for this session (soft and hard limits)
ulimit -S -c 0
ulimit -H -c 0 2>/dev/null || true

# Environment variables to disable Electron/Chromium crash reporting
export ELECTRON_DISABLE_CRASH_REPORTER=1
export CHROME_CRASHPAD_PIPE_NAME=/dev/null
export BREAKPAD_DUMP_LOCATION=/dev/null

# Launch original Antigravity binary with comprehensive flags
exec /usr/share/antigravity/antigravity.bin \
  --no-sandbox \
  --disable-setuid-sandbox \
  --disable-gpu \
  --disable-dev-shm-usage \
  --disable-crash-reporter \
  --disable-breakpad \
  --no-crash-upload \
  --crash-dumps-dir=/dev/null \
  --disable-component-update \
  --disable-background-networking \
  --disable-sync \
  "$@"
EOL

chmod +x /usr/share/antigravity/antigravity

# Also keep the wrapper in /usr/local/bin for manual use if needed
cp /usr/share/antigravity/antigravity /usr/local/bin/antigravity-wrapper

# Update desktop entries to ensure they work (though now they'll use the wrapper automatically)
if [ -f /usr/share/applications/antigravity.desktop ]; then
  # Ensure desktop entry points to the wrapper location
  sed -i 's|^Exec=/usr/share/antigravity/antigravity\.bin|Exec=/usr/share/antigravity/antigravity|g' /usr/share/applications/antigravity.desktop
  sed -i 's|^Exec=/usr/local/bin/antigravity-wrapper|Exec=/usr/share/antigravity/antigravity|g' /usr/share/applications/antigravity.desktop
fi

# Copy desktop entry to Desktop
if [ -f /usr/share/applications/antigravity.desktop ]; then
  cp /usr/share/applications/antigravity.desktop $HOME/Desktop/
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
