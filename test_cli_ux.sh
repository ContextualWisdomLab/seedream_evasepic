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

if ! awk '
  previous == "--concurrent-fragments" && $0 == "4" { found = 1 }
  { previous = $0 }
  END { exit !found }
' "$ARGS_FILE"; then
  echo "FAIL: yt-dlp missing --concurrent-fragments 4 flag" >&2
  exit 1
fi

echo "PASS: yt-dlp URL is protected by -- argument separator"
echo "====================================="

echo "=== Testing download cache-hit short circuit ==="
CACHED_OUTPUT="$TMP_DIR/cached-reference.mp4"
CACHED_ARGS_FILE="$TMP_DIR/cached-yt-dlp.args"
EXPECTED_CACHED_OUTPUT="$TMP_DIR/cached-reference.expected"
CACHE_HIT_PATH="$TMP_DIR/cache-hit-bin"
mkdir -p -- "$CACHE_HIT_PATH"
ln -s -- "$(command -v dirname)" "$CACHE_HIT_PATH/dirname"
printf 'existing-video-payload\n\001\377\n' > "$CACHED_OUTPUT"
cp -- "$CACHED_OUTPUT" "$EXPECTED_CACHED_OUTPUT"

for forbidden_command in yt-dlp brew pip3 pip; do
  if PATH="$CACHE_HIT_PATH" command -v "$forbidden_command" >/dev/null 2>&1; then
    echo "FAIL: cache-hit PATH must exclude $forbidden_command" >&2
    exit 1
  fi
done

set +e
cached_output="$(
  PATH="$CACHE_HIT_PATH" \
  YT_DLP_ARGS_FILE="$CACHED_ARGS_FILE" \
    /bin/bash "$SCRIPT_DIR/download-reference.sh" \
      "https://example.invalid/cached-video" "$CACHED_OUTPUT" 2>&1
)"
cached_status=$?
set -e

if [ "$cached_status" -ne 0 ]; then
  echo "FAIL: non-empty cached output must return success" >&2
  printf '%s\n' "$cached_output" >&2
  exit 1
fi
if [ -e "$CACHED_ARGS_FILE" ]; then
  echo "FAIL: cache hit must not invoke yt-dlp" >&2
  cat "$CACHED_ARGS_FILE" >&2
  exit 1
fi
if ! cmp -s -- "$EXPECTED_CACHED_OUTPUT" "$CACHED_OUTPUT"; then
  echo "FAIL: cache hit must preserve the existing artifact byte-for-byte" >&2
  exit 1
fi
if ! grep -q -F "File already exists, skipping download:" <<< "$cached_output"; then
  echo "FAIL: cache hit must explain why the download was skipped" >&2
  printf '%s\n' "$cached_output" >&2
  exit 1
fi

echo "PASS: non-empty regular file skips yt-dlp and preserves the artifact"
echo "====================================="

echo "=== Testing zero-byte output cache miss ==="
EMPTY_OUTPUT="$TMP_DIR/empty-reference.mp4"
EMPTY_ARGS_FILE="$TMP_DIR/empty-yt-dlp.args"
: > "$EMPTY_OUTPUT"

PATH="$TMP_DIR:$PATH" \
YT_DLP_ARGS_FILE="$EMPTY_ARGS_FILE" \
  bash "$SCRIPT_DIR/download-reference.sh" \
    "https://example.invalid/empty-video" "$EMPTY_OUTPUT" >/dev/null

if [ ! -f "$EMPTY_ARGS_FILE" ]; then
  echo "FAIL: zero-byte output must not be treated as a cache hit" >&2
  exit 1
fi
if ! grep -q -F -- "https://example.invalid/empty-video" "$EMPTY_ARGS_FILE"; then
  echo "FAIL: zero-byte cache miss must invoke yt-dlp with the original URL" >&2
  cat "$EMPTY_ARGS_FILE" >&2
  exit 1
fi

echo "PASS: zero-byte regular file remains a cache miss"
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
if ! bash "$SCRIPT_DIR/download-reference.sh" 2>&1 | grep -q "Error: Missing required argument: <url>"; then
  echo "FAIL: download-reference.sh did not print explicit error message for missing <url>" >&2
  exit 1
fi
if ! bash "$SCRIPT_DIR/extract-frames.sh" 2>&1 | grep -q "Error: Missing required argument: <video_path>"; then
  echo "FAIL: extract-frames.sh did not print explicit error message for missing <video_path>" >&2
  exit 1
fi
if ! bash "$SCRIPT_DIR/transcribe.sh" 2>&1 | grep -q "Error: Missing required argument: <audio_path>"; then
  echo "FAIL: transcribe.sh did not print explicit error message for missing <audio_path>" >&2
  exit 1
fi
echo "PASS: scripts print explicit error messages for missing arguments"
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

echo "=== Testing auto-install PATH validation ==="
PATH_TEST_DIR="$(mktemp -d)"
mkdir -p "$PATH_TEST_DIR/bin"
cat > "$PATH_TEST_DIR/bin/pip" <<'EOF'
#!/bin/bash
echo "Mock install success"
EOF
cp "$PATH_TEST_DIR/bin/pip" "$PATH_TEST_DIR/bin/pip3"
chmod +x "$PATH_TEST_DIR/bin/pip" "$PATH_TEST_DIR/bin/pip3"

PATH_TEST_STATUS=0
PATH_TEST_OUTPUT="$(PATH="$PATH_TEST_DIR/bin:/usr/bin:/bin" bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "dummy_path" 2>&1)" || PATH_TEST_STATUS=$?
if [ "$PATH_TEST_STATUS" -ne 1 ] || ! grep -Fq 'yt-dlp was installed but cannot be found in $PATH' <<< "$PATH_TEST_OUTPUT"; then
  echo "FAIL: download-reference.sh did not fail after mock install left yt-dlp outside PATH" >&2
  printf 'exit status: %s\n%s\n' "$PATH_TEST_STATUS" "$PATH_TEST_OUTPUT" >&2
  rm -rf -- "$PATH_TEST_DIR"
  exit 1
fi
rm -rf -- "$PATH_TEST_DIR"
echo "PASS: download-reference.sh warns when auto-install fails to expose tool in PATH"
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

echo "=== Testing tr process removal for performance ==="
if grep -n -F 'tr -d' "$SCRIPT_DIR/download-reference.sh"; then
  echo "FAIL: download-reference.sh must use native bash parameter expansion instead of tr" >&2
  exit 1
fi
echo "PASS: download-reference.sh uses native bash parameter expansion"
echo "====================================="

echo "=== Testing actual terminal control neutralization ==="
bash ./test_terminal_output.sh
echo "====================================="

echo "=== Testing Examples in CLI Output Should Be Actionable and Noticeable ==="
assert_colored_example() {
  local output="$1"
  local label="$2"
  if ! grep -Fq -- $'Example: \033[0;36m' <<< "$output"; then
    echo "FAIL: $label Example string is not colored with Cyan" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
  if ! grep -Fq -- $'\033[0m' <<< "$output"; then
    echo "FAIL: $label Example string does not reset terminal color" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

extract_example_output="$(bash "$SCRIPT_DIR/extract-frames.sh" "dummy" "dummy" "invalid" 2>&1 || true)"
assert_colored_example "$extract_example_output" "extract-frames.sh invalid num_frames output"

download_help_output="$(bash "$SCRIPT_DIR/download-reference.sh" --help 2>&1)"
assert_colored_example "$download_help_output" "download-reference.sh --help output"
download_error_output="$(bash "$SCRIPT_DIR/download-reference.sh" 2>&1 || true)"
assert_colored_example "$download_error_output" "download-reference.sh error output"

transcribe_help_output="$(bash "$SCRIPT_DIR/transcribe.sh" --help 2>&1)"
assert_colored_example "$transcribe_help_output" "transcribe.sh --help output"
transcribe_error_output="$(bash "$SCRIPT_DIR/transcribe.sh" "dummy_nonexistent.wav" base 2>&1 || true)"
assert_colored_example "$transcribe_error_output" "transcribe.sh error output"

echo "PASS: all three scripts keep Cyan Example highlighting and reset terminal color"
echo "====================================="

