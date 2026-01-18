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

# Log file for debugging
LOG_FILE="/tmp/session_config.log"
echo "=== Session Config Started at $(date) ===" > "$LOG_FILE"

# Wait for XFCE to be fully ready
echo "Waiting for XFCE..." >> "$LOG_FILE"
for i in {1..30}; do
  if pgrep -x "xfwm4" > /dev/null; then
    echo "xfwm4 found after $i seconds" >> "$LOG_FILE"
    break
  fi
  sleep 1
done

# Additional wait to ensure xfconf is ready
sleep 3

# Create xfwm4 config directory if it doesn't exist
mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml

# Create xfwm4 configuration file directly
cat > $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml <<'XFWM4_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="true"/>
    <property name="snap_width" type="int" value="30"/>
    <property name="wrap_windows" type="bool" value="false"/>
    <property name="wrap_resistance" type="int" value="10"/>
    <property name="margin_left" type="int" value="0"/>
    <property name="margin_right" type="int" value="0"/>
    <property name="margin_top" type="int" value="0"/>
    <property name="margin_bottom" type="int" value="0"/>
    <property name="easy_click" type="string" value="Alt"/>
    <property name="prevent_focus_stealing" type="bool" value="false"/>
    <property name="placement_ratio" type="int" value="20"/>
  </property>
</channel>
XFWM4_EOF

echo "xfwm4.xml config file created" >> "$LOG_FILE"

# Also try to set via xfconf-query as backup
if command -v xfconf-query &> /dev/null; then
  echo "Applying settings via xfconf-query..." >> "$LOG_FILE"
  xfconf-query -c xfwm4 -p /general/tile_on_move -n -t bool -s true 2>> "$LOG_FILE" || true
  xfconf-query -c xfwm4 -p /general/snap_to_border -n -t bool -s true 2>> "$LOG_FILE" || true
  xfconf-query -c xfwm4 -p /general/snap_to_windows -n -t bool -s true 2>> "$LOG_FILE" || true
  xfconf-query -c xfwm4 -p /general/snap_width -n -t int -s 30 2>> "$LOG_FILE" || true
  xfconf-query -c xfwm4 -p /general/wrap_windows -n -t bool -s false 2>> "$LOG_FILE" || true
  xfconf-query -c xfwm4 -p /general/wrap_resistance -n -t int -s 10 2>> "$LOG_FILE" || true
  xfconf-query -c xfwm4 -p /general/easy_click -n -t string -s "Alt" 2>> "$LOG_FILE" || true
  echo "xfconf-query commands executed" >> "$LOG_FILE"
fi

# Restart xfwm4 to apply changes
echo "Restarting xfwm4..." >> "$LOG_FILE"
xfwm4 --replace &
sleep 2

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
