#!/bin/bash
# Test script to verify CLI UX and argument-safety enhancements.

set -u

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
FAILURES=0

run_case() {
  local label="$1"
  local expected="$2"
  shift 2

  echo "=== $label ==="
  "$@"
  local rc=$?
  echo "Exit code: $rc"
  if [ "$rc" -ne "$expected" ]; then
    echo "Expected exit code: $expected"
    FAILURES=$((FAILURES + 1))
  fi
  echo "====================================="
}

run_case "download-reference.sh --help" 0 bash "$SCRIPT_DIR/download-reference.sh" --help
run_case "download-reference.sh missing args" 2 bash "$SCRIPT_DIR/download-reference.sh"
run_case "extract-frames.sh --help" 0 bash "$SCRIPT_DIR/extract-frames.sh" --help
run_case "extract-frames.sh missing args" 2 bash "$SCRIPT_DIR/extract-frames.sh"
run_case "transcribe.sh --help" 0 bash "$SCRIPT_DIR/transcribe.sh" --help
run_case "transcribe.sh missing args" 2 bash "$SCRIPT_DIR/transcribe.sh"

rm -f /tmp/seedream-evasepic-injection-proof
run_case \
  "extract-frames.sh rejects injected num_frames" \
  1 \
  bash "$SCRIPT_DIR/extract-frames.sh" /tmp/missing-video.mp4 /tmp/seedream-evasepic-out '1;touch /tmp/seedream-evasepic-injection-proof'

if [ -e /tmp/seedream-evasepic-injection-proof ]; then
  echo "Injection proof file was created unexpectedly."
  FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -ne 0 ]; then
  echo "$FAILURES CLI UX test(s) failed."
  exit 1
fi

echo "All CLI UX tests passed."
