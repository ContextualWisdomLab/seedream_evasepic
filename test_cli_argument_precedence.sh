#!/bin/bash

set -euo pipefail

SCRIPT="plugins/seedream-evasepic/skills/analyze-reference-video/scripts/transcribe.sh"
status=0
output="$(bash "$SCRIPT" "" definitely-not-a-model 2>&1)" || status=$?

if [ "$status" -ne 2 ]; then
  printf 'FAIL: missing audio with an invalid optional model returned %s; expected 2\n' "$status" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

if ! grep -Fq -- 'Error: Missing required argument: <audio_path>' <<< "$output"; then
  printf 'FAIL: required <audio_path> was not reported before optional model validation\n' >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

if grep -Fq -- 'Invalid model specified' <<< "$output"; then
  printf 'FAIL: optional model validation ran before the missing required <audio_path> check\n' >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

printf 'PASS: required audio admission precedes optional model validation\n'
