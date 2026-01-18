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

# Configure Windows-like Tiling (Snapping)
# Wait for xfconfd to be ready
sleep 5

# Enable tiling when moving to edges (main feature for drag-to-corner)
xfconf-query -c xfwm4 -p /general/tile_on_move -n -t bool -s true

# Enable snapping to borders
xfconf-query -c xfwm4 -p /general/snap_to_border -n -t bool -s true

# Enable snapping to other windows
xfconf-query -c xfwm4 -p /general/snap_to_windows -n -t bool -s true

# Set snap width (pixel distance to trigger snap - increased for touch screens)
xfconf-query -c xfwm4 -p /general/snap_width -n -t int -s 30

# Disable wrap workspaces when dragging off screen
xfconf-query -c xfwm4 -p /general/wrap_windows -n -t bool -s false

# Enable wrap resistance (helps with edge detection)
xfconf-query -c xfwm4 -p /general/wrap_resistance -n -t int -s 10

# Set margin width for better edge detection
xfconf-query -c xfwm4 -p /general/margin_left -n -t int -s 0
xfconf-query -c xfwm4 -p /general/margin_right -n -t int -s 0
xfconf-query -c xfwm4 -p /general/margin_top -n -t int -s 0
xfconf-query -c xfwm4 -p /general/margin_bottom -n -t int -s 0

# Enable easy click (allows moving windows by Alt+Click anywhere)
xfconf-query -c xfwm4 -p /general/easy_click -n -t string -s "Alt"

# Restart xfwm4 to apply changes
xfwm4 --replace &
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
