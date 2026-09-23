#!/bin/bash
# Regression contract for media-tool operands whose relative paths begin with '-'.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
EXTRACT_SCRIPT="$ROOT/plugins/seedream-evasepic/skills/analyze-reference-video/scripts/extract-frames.sh"
TRANSCRIBE_SCRIPT="$ROOT/plugins/seedream-evasepic/skills/analyze-reference-video/scripts/transcribe.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT
WORK_DIR="$TMP_DIR/work"
mkdir -p -- "$WORK_DIR"
: > "$WORK_DIR/-input.mp4"
: > "$WORK_DIR/-audio.wav"

cat > "$TMP_DIR/ffprobe" <<'EOF'
#!/bin/bash
set -eu
printf '%s\n' \
  'duration=1' \
  'width=16' \
  'height=16' \
  'r_frame_rate=1/1' \
  'codec_type=video'
EOF
chmod +x "$TMP_DIR/ffprobe"

cat > "$TMP_DIR/ffmpeg" <<'EOF'
#!/bin/bash
set -eu
expect_input=0
saw_input=0
saw_output=0
for arg in "$@"; do
  if [ "$expect_input" -eq 1 ]; then
    [ "$arg" = './-input.mp4' ] || {
      printf 'unsafe input operand: %s\n' "$arg" >&2
      exit 65
    }
    saw_input=1
    expect_input=0
    continue
  fi
  if [ "$arg" = '-i' ]; then
    expect_input=1
    continue
  fi
  case "$arg" in
    -output/*)
      printf 'unsafe output operand: %s\n' "$arg" >&2
      exit 66
      ;;
    ./-output/frame_%03d.jpg)
      saw_output=1
      ;;
  esac
done
[ "$saw_input" -eq 1 ] || { echo 'missing input operand' >&2; exit 67; }
[ "$saw_output" -eq 1 ] || { echo 'missing normalized output operand' >&2; exit 68; }
EOF
chmod +x "$TMP_DIR/ffmpeg"

(
  cd -- "$WORK_DIR"
  FFMPEG="$TMP_DIR/ffmpeg" \
  FFPROBE="$TMP_DIR/ffprobe" \
    bash "$EXTRACT_SCRIPT" '-input.mp4' '-output' 1 >/dev/null
)

cat > "$TMP_DIR/whisper" <<'EOF'
#!/bin/bash
set -eu
last=''
for arg in "$@"; do
  last="$arg"
done
[ "$last" = './-audio.wav' ] || {
  printf 'unsafe whisper input operand: %s\n' "$last" >&2
  exit 69
}
EOF
chmod +x "$TMP_DIR/whisper"

(
  cd -- "$WORK_DIR"
  PATH="$TMP_DIR:$PATH" bash "$TRANSCRIBE_SCRIPT" '-audio.wav' base >/dev/null
)

printf '%s\n' 'PASS: leading-dash media paths are passed as operands'
