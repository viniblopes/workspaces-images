#!/bin/bash
# Script to clean up existing core dump files from Desktop
# Run this in the current Kasm session to remove existing core files

echo "Searching for core dump files on Desktop..."

CORE_FILES=$(find ~/Desktop -name "core.*" -type f 2>/dev/null)

if [ -z "$CORE_FILES" ]; then
  echo "No core dump files found on Desktop."
  exit 0
fi

echo "Found the following core dump files:"
echo "$CORE_FILES" | while read -r file; do
  SIZE=$(du -h "$file" | cut -f1)
  echo "  - $file ($SIZE)"
done

echo ""
read -p "Do you want to delete these files? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Deleting core dump files..."
  echo "$CORE_FILES" | while read -r file; do
    rm -f "$file" && echo "  ✓ Deleted: $file"
  done
  echo "Cleanup complete!"
else
  echo "Cleanup cancelled."
fi
