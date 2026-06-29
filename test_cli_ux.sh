#!/bin/bash
# Test script to verify CLI UX enhancements (ANSI color codes)

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"

echo "=== Testing download-reference.sh ==="
bash "$SCRIPT_DIR/download-reference.sh"
EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"
if [ "$EXIT_CODE" -ne 2 ]; then
  echo "Failed: Expected exit code 2 when missing arguments"
  exit 1
fi
bash "$SCRIPT_DIR/download-reference.sh" -h > /dev/null
EXIT_CODE=$?
echo "Help flag exit code: $EXIT_CODE"
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "Failed: Expected exit code 0 when passing -h"
  exit 1
fi
echo "====================================="

echo "=== Testing extract-frames.sh ==="
bash "$SCRIPT_DIR/extract-frames.sh"
EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"
if [ "$EXIT_CODE" -ne 2 ]; then
  echo "Failed: Expected exit code 2 when missing arguments"
  exit 1
fi
bash "$SCRIPT_DIR/extract-frames.sh" -h > /dev/null
EXIT_CODE=$?
echo "Help flag exit code: $EXIT_CODE"
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "Failed: Expected exit code 0 when passing -h"
  exit 1
fi
echo "====================================="

echo "=== Testing transcribe.sh ==="
bash "$SCRIPT_DIR/transcribe.sh"
EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"
if [ "$EXIT_CODE" -ne 2 ]; then
  echo "Failed: Expected exit code 2 when missing arguments"
  exit 1
fi
bash "$SCRIPT_DIR/transcribe.sh" -h > /dev/null
EXIT_CODE=$?
echo "Help flag exit code: $EXIT_CODE"
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "Failed: Expected exit code 0 when passing -h"
  exit 1
fi
echo "====================================="
echo "All tests passed successfully!"
