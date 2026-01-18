#!/usr/bin/env bash
set -e

# Custom startup script for devbox image
# This script sources environment variables and then calls the DinD startup

echo "Starting devbox initialization..."

# Configure Session Autostart (Keyboard & Window Snapping)
mkdir -p $HOME/.config/autostart
mkdir -p $HOME/.local/bin

# Create session setup script
cat > $HOME/.local/bin/session_config.sh <<'EOF'
#!/bin/bash
# 1. Configure formatting and inputs
setxkbmap -layout br,us -variant abnt2, -option grp:alt_shift_toggle

# 2. Configure Windows-like Tiling (Snapping)
# Wait for xfconfd
sleep 3
# Enable tiling when moving to edges
xfconf-query -c xfwm4 -p /general/tile_on_move -n -t bool -s true
# Enable snapping to borders
xfconf-query -c xfwm4 -p /general/snap_to_border -n -t bool -s true
# Enable snapping to other windows
xfconf-query -c xfwm4 -p /general/snap_to_windows -n -t bool -s true
# Set snap width (pixel distance to grab the window)
xfconf-query -c xfwm4 -p /general/snap_width -n -t int -s 20
# Disable wrap workspaces when dragging off screen (improves snapping feel)
xfconf-query -c xfwm4 -p /general/wrap_windows -n -t bool -s false
EOF

chmod +x $HOME/.local/bin/session_config.sh

# Create Desktop Entry for Autostart
cat > $HOME/.config/autostart/session_config.desktop <<EOL
[Desktop Entry]
Type=Application
Name=Session Config
Exec=/home/kasm-user/.local/bin/session_config.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL

chown -R 1000:1000 $HOME/.config $HOME/.local 2>/dev/null || true

# Source environment variables for development tools
if [ -f /etc/profile.d/flutter.sh ]; then
  source /etc/profile.d/flutter.sh
fi

if [ -f /etc/profile.d/fvm.sh ]; then
  source /etc/profile.d/fvm.sh
fi

#if [ -f /etc/profile.d/android.sh ]; then
#  source /etc/profile.d/android.sh
#fi

# Create workspace directories
mkdir -p $HOME/workspace
#mkdir -p $HOME/.android
mkdir -p $HOME/.fvm

# Set proper permissions
chown -R 1000:1000 $HOME/workspace 2>/dev/null || true
#chown -R 1000:1000 $HOME/.android 2>/dev/null || true
chown -R 1000:1000 $HOME/.fvm 2>/dev/null || true

# Display environment info
echo "==================================="
echo "Development Environment Ready!"
echo "==================================="
echo "Flutter: $(which flutter 2>/dev/null || echo 'Restart terminal to use')"
#echo "Android SDK: ${ANDROID_HOME:-Not set}"
echo "==================================="

# Call the DinD custom startup (which handles Docker daemon)
if [ -f /dockerstartup/dind_startup.sh ]; then
  source /dockerstartup/dind_startup.sh
else
  # Fallback to default startup
  exec "$@"
fi
