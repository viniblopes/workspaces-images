#!/bin/bash
# Emergency cleanup script for core dumps
# Run this if the Kasm container won't start due to core dumps
# Usage: ./emergency-cleanup.sh [container-name-or-id]

set -e

CONTAINER="${1:-}"

if [ -z "$CONTAINER" ]; then
  echo "Usage: $0 <container-name-or-id>"
  echo ""
  echo "This script removes core dump files from a Kasm container"
  echo "Use this when the container won't start due to disk space issues"
  echo ""
  echo "Example:"
  echo "  $0 kasm_workspace_12345"
  exit 1
fi

echo "🔍 Checking container: $CONTAINER"

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  if ! docker ps -a --format '{{.ID}}' | grep -q "^${CONTAINER}"; then
    echo "❌ Container not found: $CONTAINER"
    exit 1
  fi
fi

echo "✅ Container found"
echo ""
echo "🔍 Searching for core dump files..."

# Try to find and list core dumps
CORE_FILES=$(docker exec "$CONTAINER" find /home/kasm-user/Desktop -name "core.*" -type f 2>/dev/null || true)

if [ -z "$CORE_FILES" ]; then
  echo "✅ No core dump files found on Desktop"
  
  # Check home directory too
  CORE_FILES=$(docker exec "$CONTAINER" find /home/kasm-user -maxdepth 1 -name "core.*" -type f 2>/dev/null || true)
  
  if [ -z "$CORE_FILES" ]; then
    echo "✅ No core dump files found in home directory either"
    exit 0
  fi
fi

echo "⚠️  Found core dump files:"
echo "$CORE_FILES" | while read -r file; do
  SIZE=$(docker exec "$CONTAINER" du -h "$file" 2>/dev/null | cut -f1 || echo "unknown")
  echo "  - $file ($SIZE)"
done

echo ""
read -p "❓ Do you want to delete these files? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "🗑️  Deleting core dump files..."
  
  # Delete from Desktop
  docker exec "$CONTAINER" bash -c "find /home/kasm-user/Desktop -name 'core.*' -type f -delete" 2>/dev/null || true
  
  # Delete from home
  docker exec "$CONTAINER" bash -c "find /home/kasm-user -maxdepth 1 -name 'core.*' -type f -delete" 2>/dev/null || true
  
  echo "✅ Cleanup complete!"
  echo ""
  echo "📊 Disk usage after cleanup:"
  docker exec "$CONTAINER" df -h /home/kasm-user 2>/dev/null || true
else
  echo "❌ Cleanup cancelled"
  exit 1
fi
