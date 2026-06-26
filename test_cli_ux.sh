#!/bin/bash
# Test script to verify CLI UX enhancements (ANSI color codes)

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"

echo "=== Testing download-reference.sh (no args) ==="
bash "$SCRIPT_DIR/download-reference.sh"
echo "Exit code: $?"
echo "====================================="

echo "=== Testing download-reference.sh (-h) ==="
bash "$SCRIPT_DIR/download-reference.sh" -h
echo "Exit code: $?"
echo "====================================="

echo "=== Testing extract-frames.sh (no args) ==="
bash "$SCRIPT_DIR/extract-frames.sh"
echo "Exit code: $?"
echo "====================================="

echo "=== Testing extract-frames.sh (--help) ==="
bash "$SCRIPT_DIR/extract-frames.sh" --help
echo "Exit code: $?"
echo "====================================="

echo "=== Testing transcribe.sh (no args) ==="
bash "$SCRIPT_DIR/transcribe.sh"
echo "Exit code: $?"
echo "====================================="

echo "=== Testing transcribe.sh (-h) ==="
bash "$SCRIPT_DIR/transcribe.sh" -h
echo "Exit code: $?"
echo "====================================="
