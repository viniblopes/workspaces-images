#!/usr/bin/env bash
# Antigravity Safe Launch Script
# Alternative launcher with extra safety checks and monitoring
# Usage: Run this instead of the normal Antigravity launcher if issues persist

set -e

echo "🛡️  Antigravity Safe Launch"
echo "=========================="

# 1. Verify core dumps are disabled
echo "[1/5] Verifying core dump settings..."
CURRENT_ULIMIT=$(ulimit -c)
if [ "$CURRENT_ULIMIT" != "0" ]; then
  echo "⚠️  WARNING: ulimit -c is $CURRENT_ULIMIT, forcing to 0"
  ulimit -S -c 0
  ulimit -H -c 0 2>/dev/null || true
else
  echo "✅ Core dumps disabled (ulimit -c = 0)"
fi

# 2. Clean up any existing core dumps
echo "[2/5] Cleaning existing core dumps..."
CORE_COUNT=$(find $HOME -maxdepth 2 -name "core.*" -type f 2>/dev/null | wc -l)
if [ "$CORE_COUNT" -gt 0 ]; then
  echo "⚠️  Found $CORE_COUNT core dump files, removing..."
  find $HOME/Desktop -name "core.*" -type f -delete 2>/dev/null || true
  find $HOME -maxdepth 2 -name "core.*" -type f -delete 2>/dev/null || true
  find $HOME/.config -name "core.*" -type f -delete 2>/dev/null || true
  echo "✅ Core dumps cleaned"
else
  echo "✅ No core dumps found"
fi

# 3. Set environment variables
echo "[3/5] Setting crash prevention environment variables..."
export ELECTRON_DISABLE_CRASH_REPORTER=1
export CHROME_CRASHPAD_PIPE_NAME=/dev/null
export BREAKPAD_DUMP_LOCATION=/dev/null
echo "✅ Environment configured"

# 4. Check disk space
echo "[4/5] Checking disk space..."
DISK_USAGE=$(df -h $HOME | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
  echo "⚠️  WARNING: Disk usage is ${DISK_USAGE}% - consider cleaning up"
else
  echo "✅ Disk usage: ${DISK_USAGE}%"
fi

# 5. Launch Antigravity
echo "[5/5] Launching Antigravity..."
echo "=========================="
echo ""

# Use the wrapper script which has all the flags
exec /usr/local/bin/antigravity-wrapper "$@"
