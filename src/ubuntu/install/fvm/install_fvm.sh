#!/usr/bin/env bash
set -ex

# Install FVM (Flutter Version Manager)

# Ensure Flutter is installed first
if [ ! -d "/opt/flutter/flutter" ]; then
  echo "Flutter must be installed before FVM. Please install Flutter first."
  exit 1
fi

# Set up Flutter environment
export FLUTTER_HOME=/opt/flutter/flutter
export PATH=$FLUTTER_HOME/bin:$PATH
export PUB_CACHE=/opt/flutter/.pub-cache

# Create pub cache directory
mkdir -p /opt/flutter/.pub-cache
chown -R 1000:1000 /opt/flutter/.pub-cache

# Install FVM via pub global
sudo -u "#1000" bash -c "export PATH=/opt/flutter/flutter/bin:\$PATH && export PUB_CACHE=/opt/flutter/.pub-cache && flutter pub global activate fvm"

# Add FVM to PATH
cat > /etc/profile.d/fvm.sh <<EOL
export PUB_CACHE=/opt/flutter/.pub-cache
export PATH=\$PUB_CACHE/bin:\$PATH
export FVM_HOME=\$HOME/.fvm
EOL

chmod +x /etc/profile.d/fvm.sh

# Create FVM directory for default user
mkdir -p /home/kasm-default-profile/.fvm
chown -R 1000:1000 /home/kasm-default-profile/.fvm

# Create helpful aliases script
cat > /etc/profile.d/fvm-aliases.sh <<EOL
# FVM aliases
alias fvm-list='fvm list'
alias fvm-install='fvm install'
alias fvm-use='fvm use'
alias fvm-releases='fvm releases'
EOL

chmod +x /etc/profile.d/fvm-aliases.sh

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
