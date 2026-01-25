#!/usr/bin/env bash
set -ex

# Disable unnecessary services to reduce CPU usage
# This script disables whoopsie (crash reporter) and cups (printing service)
# which are not needed in a Kasm container environment

echo "Disabling unnecessary services for CPU optimization..."

# Disable whoopsie (Ubuntu crash reporter)
# This service consumes CPU monitoring for crashes and is not needed in containers
if systemctl list-unit-files | grep -q whoopsie; then
    systemctl disable whoopsie.service 2>/dev/null || true
    systemctl disable whoopsie.path 2>/dev/null || true
    systemctl mask whoopsie.service 2>/dev/null || true
    echo "Whoopsie disabled"
fi

# Also disable via init.d if present
if [ -f /etc/init.d/whoopsie ]; then
    update-rc.d whoopsie disable 2>/dev/null || true
    echo "Whoopsie disabled via init.d"
fi

# Disable CUPS (printing service)
# Printing is rarely needed in Kasm environments
if systemctl list-unit-files | grep -q cups; then
    systemctl disable cups.service 2>/dev/null || true
    systemctl disable cups.socket 2>/dev/null || true
    systemctl disable cups.path 2>/dev/null || true
    systemctl disable cups-browsed.service 2>/dev/null || true
    systemctl mask cups.service 2>/dev/null || true
    echo "CUPS disabled"
fi

# Also disable via init.d if present
if [ -f /etc/init.d/cups ]; then
    update-rc.d cups disable 2>/dev/null || true
    echo "CUPS disabled via init.d"
fi

# Stop services if currently running (for testing in running container)
service whoopsie stop 2>/dev/null || true
service cups stop 2>/dev/null || true

echo "Service optimization complete"
echo "Disabled services: whoopsie, cups"
