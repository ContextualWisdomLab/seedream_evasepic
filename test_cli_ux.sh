#!/bin/bash
# Test script to verify CLI UX enhancements (ANSI color codes)

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"

echo "=== Testing download-reference.sh ==="
bash "$SCRIPT_DIR/download-reference.sh"
echo "Exit code: $?"
echo "====================================="

echo "=== Testing extract-frames.sh ==="
bash "$SCRIPT_DIR/extract-frames.sh"
echo "Exit code: $?"
echo "====================================="

echo "=== Testing transcribe.sh ==="
bash "$SCRIPT_DIR/transcribe.sh"
echo "Exit code: $?"
echo "====================================="
echo "=== Testing extract-frames.sh with dummy video ==="
ffmpeg -f lavfi -i testsrc=duration=1:size=1280x720:rate=30 -y dummy_test_coverage.mp4 >/dev/null 2>&1
mkdir -p out_test_coverage
bash "$SCRIPT_DIR/extract-frames.sh" dummy_test_coverage.mp4 out_test_coverage 12 >/dev/null || true
if [ -f out_test_coverage/metadata.txt ] && [ -f out_test_coverage/frame_001.jpg ]; then
  echo "extract-frames.sh success"
else
  echo "extract-frames.sh failed"
fi
rm -rf dummy_test_coverage.mp4 out_test_coverage
echo "====================================="
