#!/usr/bin/env bash
set -e

# Custom startup script for devbox image
# This script sources environment variables and then calls the DinD startup

echo "Starting devbox initialization..."

# Disable core dumps system-wide
ulimit -c 0
echo "Core dumps disabled"

# Configure Session Autostart (Keyboard & Window Snapping)
mkdir -p $HOME/.config/autostart
mkdir -p $HOME/.local/bin

# Create session setup script
cat > $HOME/.local/bin/session_config.sh <<'EOF'
#!/bin/bash

# Log file for debugging
LOG_FILE="/tmp/session_config.log"
echo "=== Session Config Started at $(date) ===" > "$LOG_FILE"

# Wait for XFCE to be fully ready
echo "Waiting for XFCE..." >> "$LOG_FILE"
for i in {1..30}; do
  if pgrep -x "xfwm4" > /dev/null && pgrep -x "xfconfd" > /dev/null; then
    echo "xfwm4 and xfconfd found after $i seconds" >> "$LOG_FILE"
    break
  fi
  sleep 1
done

# Additional wait to ensure xfconf is ready
sleep 2

# Apply window tiling settings via xfconf-query
if command -v xfconf-query &> /dev/null; then
  echo "Applying window tiling settings..." >> "$LOG_FILE"
  
  # Enable tiling when moving to edges (main feature for drag-to-corner)
  xfconf-query -c xfwm4 -p /general/tile_on_move -s true 2>> "$LOG_FILE" || \
    xfconf-query -c xfwm4 -p /general/tile_on_move -n -t bool -s true 2>> "$LOG_FILE"
  
  # Enable snapping to borders
  xfconf-query -c xfwm4 -p /general/snap_to_border -s true 2>> "$LOG_FILE" || \
    xfconf-query -c xfwm4 -p /general/snap_to_border -n -t bool -s true 2>> "$LOG_FILE"
  
  # Enable snapping to other windows
  xfconf-query -c xfwm4 -p /general/snap_to_windows -s true 2>> "$LOG_FILE" || \
    xfconf-query -c xfwm4 -p /general/snap_to_windows -n -t bool -s true 2>> "$LOG_FILE"
  
  # Set snap width (pixel distance to trigger snap - increased for touch screens)
  xfconf-query -c xfwm4 -p /general/snap_width -s 30 2>> "$LOG_FILE" || \
    xfconf-query -c xfwm4 -p /general/snap_width -n -t int -s 30 2>> "$LOG_FILE"
  
  # Disable wrap workspaces when dragging off screen
  xfconf-query -c xfwm4 -p /general/wrap_windows -s false 2>> "$LOG_FILE" || \
    xfconf-query -c xfwm4 -p /general/wrap_windows -n -t bool -s false 2>> "$LOG_FILE"
  
  echo "Window tiling settings applied" >> "$LOG_FILE"
else
  echo "xfconf-query not found!" >> "$LOG_FILE"
fi

echo "=== Session Config Completed at $(date) ===" >> "$LOG_FILE"
echo "Check /tmp/session_config.log for details"
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
