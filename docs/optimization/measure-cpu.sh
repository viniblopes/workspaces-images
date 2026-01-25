#!/bin/bash
# Script para medir CPU usage e documentar progresso
# Usage: ./measure-cpu.sh [step_name]

STEP_NAME="${1:-baseline}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
OUTPUT_FILE="docs/optimization/measurements/${STEP_NAME}_$(date '+%Y%m%d_%H%M%S').txt"

# Create measurements directory if it doesn't exist
mkdir -p docs/optimization/measurements

echo "========================================" | tee "$OUTPUT_FILE"
echo "CPU Measurement - $STEP_NAME" | tee -a "$OUTPUT_FILE"
echo "Timestamp: $TIMESTAMP" | tee -a "$OUTPUT_FILE"
echo "========================================" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Load average
echo "=== Load Average ===" | tee -a "$OUTPUT_FILE"
uptime | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Top processes
echo "=== Top 15 CPU Consumers ===" | tee -a "$OUTPUT_FILE"
ps aux --sort=-%cpu | head -16 | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Memory usage
echo "=== Memory Usage ===" | tee -a "$OUTPUT_FILE"
free -h | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Running services
echo "=== Running Services ===" | tee -a "$OUTPUT_FILE"
service --status-all 2>&1 | grep '\[ + \]' | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Specific processes of interest
echo "=== Processes of Interest ===" | tee -a "$OUTPUT_FILE"
echo "Xvnc:" | tee -a "$OUTPUT_FILE"
ps aux | grep -E '[X]vnc' | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

echo "Antigravity:" | tee -a "$OUTPUT_FILE"
ps aux | grep -E '[a]ntigravity' | head -5 | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

echo "FFmpeg:" | tee -a "$OUTPUT_FILE"
ps aux | grep -E '[f]fmpeg' | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

echo "Docker:" | tee -a "$OUTPUT_FILE"
ps aux | grep -E '[d]ockerd|[c]ontainerd' | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

echo "========================================" | tee -a "$OUTPUT_FILE"
echo "Measurement saved to: $OUTPUT_FILE"
echo "========================================"
