#!/bin/bash
# Test script to verify CLI UX enhancements (ANSI color codes)

set -u

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

echo "=== Testing post-installation PATH validation for yt-dlp ==="
TEST_TMP="$(mktemp -d)"
cat > "$TEST_TMP/pip3" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$TEST_TMP/pip3"

set +e
output="$(PATH="$TEST_TMP:/usr/bin:/bin" bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "dummy_out" 2>&1)"
exit_code=$?
set -e
rm -rf -- "$TEST_TMP"

if [ "$exit_code" -ne 1 ] || ! grep -q -F "yt-dlp was installed but is not found in PATH" <<< "$output"; then
  echo "FAIL: download-reference.sh did not print explicit error message for missing PATH post-install" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi
echo "PASS: download-reference.sh prints explicit error message for missing PATH post-install"
echo "====================================="

echo "=== Testing yt-dlp argument separator ==="
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

cat > "$TMP_DIR/yt-dlp" <<'EOF'
#!/bin/bash
set -eu

printf '%s\n' "$@" > "${YT_DLP_ARGS_FILE:?}"

output=""
while [ "$#" -gt 0 ]; do
  if [ "$1" = "-o" ]; then
    shift
    output="${1:-}"
    break
  fi
  shift
done

if [ -n "$output" ]; then
  mkdir -p -- "$(dirname -- "$output")"
  : > "$output"
fi
EOF
chmod +x "$TMP_DIR/yt-dlp"

ARGS_FILE="$TMP_DIR/yt-dlp.args"
MALICIOUS_URL="--exec=touch /tmp/seedream-evasepic-pwned"
PATH="$TMP_DIR:$PATH" \
YT_DLP_ARGS_FILE="$ARGS_FILE" \
  bash "$SCRIPT_DIR/download-reference.sh" "$MALICIOUS_URL" "$TMP_DIR/reference.mp4" >/dev/null

separator_line="$(grep -n -x -F -- "--" "$ARGS_FILE" | tail -n 1 | cut -d: -f1)"
url_line="$(grep -n -F -- "$MALICIOUS_URL" "$ARGS_FILE" | tail -n 1 | cut -d: -f1)"

if [ -z "$separator_line" ] || [ -z "$url_line" ] || [ "$url_line" -ne $((separator_line + 1)) ]; then
  echo "FAIL: yt-dlp URL must be passed immediately after --" >&2
  cat "$ARGS_FILE" >&2
  exit 1
fi

echo "PASS: yt-dlp URL is protected by -- argument separator"
echo "====================================="

echo "=== Testing awk fallback variable binding ==="
if grep -n -F 'awk "BEGIN' "$SCRIPT_DIR/extract-frames.sh"; then
  echo "FAIL: extract-frames.sh must not interpolate shell variables into an awk program string" >&2
  exit 1
fi

if ! grep -n -F 'awk -v nf="$NUM_FRAMES" -v dur="$DURATION"' "$SCRIPT_DIR/extract-frames.sh"; then
  echo "FAIL: extract-frames.sh must pass NUM_FRAMES and DURATION to awk with -v bindings" >&2
  exit 1
fi

echo "PASS: awk fallback keeps dynamic values out of the awk program string"
echo "====================================="

echo "=== Testing error message clarity for missing arguments ==="
if ! bash "$SCRIPT_DIR/download-reference.sh" 2>&1 | grep -q "Error: Missing required argument(s)."; then
  echo "FAIL: download-reference.sh did not print explicit error message" >&2
  exit 1
fi
echo "PASS: download-reference.sh prints explicit error message"
echo "====================================="

echo "=== Testing usage block for invalid arguments ==="
if ! bash "$SCRIPT_DIR/transcribe.sh" "dummy.wav" "invalid_model" 2>&1 | grep -q "Usage: transcribe.sh <audio_path> \[model\]"; then
  echo "FAIL: transcribe.sh did not print usage block for invalid model" >&2
  exit 1
fi
echo "PASS: transcribe.sh prints usage block for invalid model"

if ! bash "$SCRIPT_DIR/extract-frames.sh" "dummy.mp4" "dummy_dir" "invalid_num" 2>&1 | grep -q "Usage: extract-frames.sh <video_path> <output_dir> \[num_frames\]"; then
  echo "FAIL: extract-frames.sh did not print usage block for invalid num_frames" >&2
  exit 1
fi
echo "PASS: extract-frames.sh prints usage block for invalid num_frames"
echo "====================================="

echo "=== Testing ANSI color codes in Python inline output ==="
if ! grep -q '\\033\[0;36mLoading whisper model' "$SCRIPT_DIR/transcribe.sh"; then
  echo "FAIL: transcribe.sh Python inline script does not contain ANSI color for 'Loading whisper model'" >&2
  exit 1
fi
if ! grep -q '\\033\[0;32mTranscript and segment files written' "$SCRIPT_DIR/transcribe.sh"; then
  echo "FAIL: transcribe.sh Python inline script does not contain ANSI color for completion" >&2
  exit 1
fi
echo "PASS: transcribe.sh Python inline script contains trusted ANSI color codes"
echo "====================================="

echo "=== Testing help flag position flexibility ==="
if ! bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "--help" | grep -q "Download Reference Video Script"; then
  echo "FAIL: download-reference.sh did not recognize --help as second argument" >&2
  exit 1
fi
echo "PASS: download-reference.sh recognizes --help at any position"
echo "====================================="

echo "=== Testing usage block on file not found error ==="
if ! bash "$SCRIPT_DIR/transcribe.sh" "dummy_nonexistent.wav" "base" 2>&1 | grep -q "Usage: transcribe.sh <audio_path> \[model\]"; then
  echo "FAIL: transcribe.sh did not print usage block for file not found error" >&2
  exit 1
fi
echo "PASS: transcribe.sh prints usage block for file not found error"
echo "====================================="

echo "=== Testing ffprobe dependency preflight ==="
DUMMY_VIDEO="$TMP_DIR/ffprobe-preflight.mp4"
: > "$DUMMY_VIDEO"
set +e
ffprobe_output="$(
  FFMPEG="/bin/true" \
  FFPROBE="$TMP_DIR/missing-ffprobe" \
    bash "$SCRIPT_DIR/extract-frames.sh" "$DUMMY_VIDEO" "$TMP_DIR/ffprobe-output" 12 2>&1
)"
ffprobe_status=$?
set -e
if [ "$ffprobe_status" -ne 1 ] || ! grep -q -F "Error: ffprobe not found." <<< "$ffprobe_output"; then
  echo "FAIL: extract-frames.sh must fail before probing when ffprobe is unavailable" >&2
  printf '%s\n' "$ffprobe_output" >&2
  exit 1
fi
if ! grep -q -F "Install with: brew install ffmpeg" <<< "$ffprobe_output"; then
  echo "FAIL: ffprobe preflight must provide an actionable installation command" >&2
  exit 1
fi
echo "PASS: extract-frames.sh reports a missing ffprobe before metadata processing"
echo "====================================="

echo "=== Testing actual terminal control neutralization ==="
bash ./test_terminal_output.sh
echo "====================================="
