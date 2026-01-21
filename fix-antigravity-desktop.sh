#!/bin/bash
# Immediate fix for Antigravity core dumps in current session

echo "==================================="
echo "Antigravity Core Dump Fix"
echo "==================================="
echo ""

# 1. Fix desktop entry to use wrapper
echo "[1/4] Updating desktop entry to use wrapper..."
if [ -f ~/Desktop/antigravity.desktop ]; then
  sed -i 's|Exec=/usr/share/antigravity/antigravity|Exec=/usr/local/bin/antigravity-wrapper|g' ~/Desktop/antigravity.desktop
  echo "  ✓ Desktop entry updated"
else
  echo "  ⚠ Desktop entry not found"
fi

# 2. Disable core dumps for current session
echo "[2/4] Disabling core dumps for current session..."
ulimit -c 0
echo "  ✓ ulimit -c set to 0"

# 3. Kill existing Antigravity processes
echo "[3/4] Stopping existing Antigravity processes..."
if pgrep antigravity > /dev/null; then
  pkill -9 antigravity
  sleep 2
  echo "  ✓ Antigravity processes stopped"
else
  echo "  ℹ No Antigravity processes running"
fi

# 4. Verify configuration
echo "[4/4] Verifying configuration..."
echo ""
echo "Desktop entry Exec line:"
grep "^Exec=" ~/Desktop/antigravity.desktop 2>/dev/null || echo "  ⚠ Could not read desktop entry"
echo ""
echo "Current ulimit -c: $(ulimit -c)"
echo ""

echo "==================================="
echo "✓ Fix applied!"
echo "==================================="
echo ""
echo "Please relaunch Antigravity from the Desktop icon."
echo "The application should now run without creating core dumps."
