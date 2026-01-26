#!/usr/bin/env bash
set -e

# VNC Quality Optimization Script
# Purpose: Fix visual artifacts during scrolling by improving KasmVNC quality settings
# This script creates a KasmVNC YAML configuration file with quality-focused settings

echo "Configuring KasmVNC for improved visual quality..."

# Create the kasmvnc config directory if it doesn't exist
mkdir -p /etc/kasmvnc

# Create the kasmvnc.yaml configuration file
cat > /etc/kasmvnc/kasmvnc.yaml << 'EOF'
# KasmVNC Quality Configuration
# Optimized to eliminate visual artifacts during scrolling and motion

encoding:
  # Increase quality settings to prevent artifacts
  max_frame_rate: 60
  
  # Dynamic quality settings - higher values = better quality
  # Range: 0 (low) to 9 (high)
  rect_encoding_mode:
    min_quality: 8  # Increased from 7 - better quality during motion/scrolling
    max_quality: 9  # Increased from 8 - maximum quality for static content
  
  # Video region detection
  video_area: 60      # Increased from 45 - better video region detection
  video_time: 3       # Decreased from 5 - faster transition to video mode
  video_out_time: 3   # How long to wait before exiting video mode
  
  # Lossless encoding settings
  treat_lossless: 7   # Decreased from 10 - more frequent lossless updates for text clarity
  
  # Prefer quality over bandwidth
  prefer_bandwidth: false  # Prioritize quality over bandwidth savings
  
  # WebP and JPEG quality settings
  webp_video_quality: 8   # High quality for WebP encoding
  jpeg_video_quality: 8   # High quality for JPEG encoding
  
  # Additional quality improvements
  compare_framebuffer: 2  # Compare framebuffer to reduce unnecessary updates
  
# Runtime configuration
runtime_configuration:
  allow_client_to_override_kasm_server_settings: true
EOF

echo "KasmVNC quality configuration created at /etc/kasmvnc/kasmvnc.yaml"
echo "Settings applied:"
echo "  - DynamicQualityMin: 8 (higher quality during motion)"
echo "  - DynamicQualityMax: 9 (maximum quality)"
echo "  - TreatLossless: 7 (more frequent lossless updates)"
echo "  - FrameRate: 60 (smooth scrolling maintained)"
echo "  - VideoArea: 60 (better video detection)"
echo "  - Quality prioritized over bandwidth"
