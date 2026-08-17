#!/bin/bash
# Verify that missing required arguments take precedence over optional-value validation.

set -euo pipefail

SCRIPT="plugins/seedream-evasepic/skills/analyze-reference-video/scripts/transcribe.sh"

set +e
output="$(bash "$SCRIPT" "" "invalid_model" 2>&1)"
status=$?
set -e

if [ "$status" -ne 2 ]; then
  echo "FAIL: missing audio path must remain a usage error with exit code 2" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

if ! grep -Fq "Error: Missing required argument: <audio_path>" <<< "$output"; then
  echo "FAIL: missing <audio_path> must be reported before optional model validation" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

if grep -Fq "Error: Invalid model specified:" <<< "$output"; then
  echo "FAIL: optional model validation must not hide the missing required audio path" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

echo "PASS: required audio-path guidance takes precedence over optional model validation"
