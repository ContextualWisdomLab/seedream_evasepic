#!/bin/bash
# Verify that malformed external probe output cannot inject terminal control bytes.

set -euo pipefail

SCRIPT="plugins/seedream-evasepic/skills/analyze-reference-video/scripts/extract-frames.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

VIDEO="$TMP_DIR/reference.mp4"
OUTPUT_DIR="$TMP_DIR/frames"
OUTPUT_FILE="$TMP_DIR/extract.out"
: > "$VIDEO"

cat > "$TMP_DIR/ffprobe" <<'STUB'
#!/bin/bash
set -euo pipefail
printf 'duration=1\n'
printf 'width=1920\033[31mPWNED\033[0m\n'
printf 'height=1080\n'
printf 'r_frame_rate=30/1\n'
printf 'codec_type=video\n'
STUB
chmod +x "$TMP_DIR/ffprobe"

cat > "$TMP_DIR/ffmpeg" <<'STUB'
#!/bin/bash
set -euo pipefail
exit 0
STUB
chmod +x "$TMP_DIR/ffmpeg"

FFPROBE="$TMP_DIR/ffprobe" \
FFMPEG="$TMP_DIR/ffmpeg" \
  bash "$SCRIPT" "$VIDEO" "$OUTPUT_DIR" 1 > "$OUTPUT_FILE" 2>&1

ATTACKER_SEQUENCE=$'\033[31mPWNED\033[0m'
if LC_ALL=C grep -Fq -- "$ATTACKER_SEQUENCE" "$OUTPUT_FILE"; then
  cat "$OUTPUT_FILE" >&2
  fail 'ffprobe-derived metadata reached the terminal with live ANSI controls'
fi

if ! grep -Fq -- '\x1B[31mPWNED\x1B[0m' "$OUTPUT_FILE"; then
  cat "$OUTPUT_FILE" >&2
  fail 'ffprobe-derived metadata was not preserved as visible neutralized text'
fi

printf 'PASS: ffprobe-derived metadata is neutralized before terminal output\n'
