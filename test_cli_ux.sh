#!/bin/bash
# Test script to verify CLI UX enhancements (ANSI color codes)

set -euo pipefail

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"

echo "=== Testing download-reference.sh ==="
if bash "$SCRIPT_DIR/download-reference.sh"; then
  command_status=0
else
  command_status=$?
fi
echo "Exit code: $command_status"
echo "====================================="

echo "=== Testing extract-frames.sh ==="
if bash "$SCRIPT_DIR/extract-frames.sh"; then
  command_status=0
else
  command_status=$?
fi
echo "Exit code: $command_status"
echo "====================================="

echo "=== Testing transcribe.sh ==="
if bash "$SCRIPT_DIR/transcribe.sh"; then
  command_status=0
else
  command_status=$?
fi
echo "Exit code: $command_status"
echo "====================================="

echo "=== Testing path traversal prevention ==="
if TRAVERSAL_OUTPUT="$(bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "../output.mp4" 2>&1)"; then
  traversal_status=0
else
  traversal_status=$?
fi
if [ "$traversal_status" -eq 0 ]; then
  echo "FAIL: download-reference.sh must return a non-zero status for path traversal" >&2
  exit 1
fi
if ! grep -q -F "Path traversal sequences (..) are not allowed in output path" <<< "$TRAVERSAL_OUTPUT"; then
  echo "FAIL: download-reference.sh must abort when output path contains path traversal sequences" >&2
  printf '%s\n' "$TRAVERSAL_OUTPUT" >&2
  exit 1
fi
echo "PASS: download-reference.sh properly aborts on path traversal sequences"
echo "====================================="

echo "=== Testing symlink path prevention ==="
SYMLINK_TMP_DIR="$(mktemp -d)"
mkdir -p "$SYMLINK_TMP_DIR/real_dir"
echo "dummy" > "$SYMLINK_TMP_DIR/real_dir/output.mp4"
ln -s "$SYMLINK_TMP_DIR/real_dir/output.mp4" "$SYMLINK_TMP_DIR/symlink.mp4"
if [ ! -L "$SYMLINK_TMP_DIR/symlink.mp4" ]; then
  echo "FAIL: file-symlink fixture was not created" >&2
  exit 1
fi
if symlink_output="$(bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "$SYMLINK_TMP_DIR/symlink.mp4" 2>&1)"; then
  symlink_status=0
else
  symlink_status=$?
fi
if [ "$symlink_status" -eq 0 ]; then
  echo "FAIL: download-reference.sh must abort when output path is a symlink" >&2
  exit 1
fi
if ! grep -q -F "Output path is a symlink. Aborting" <<< "$symlink_output"; then
  echo "FAIL: download-reference.sh must report symlink detection" >&2
  printf '%s\n' "$symlink_output" >&2
  exit 1
fi
if [ ! -L "$SYMLINK_TMP_DIR/symlink.mp4" ] \
  || [ "$(cat "$SYMLINK_TMP_DIR/real_dir/output.mp4")" != "dummy" ]; then
  echo "FAIL: rejected file symlink must remain intact without changing its target" >&2
  exit 1
fi

ln -s "$SYMLINK_TMP_DIR/real_dir" "$SYMLINK_TMP_DIR/symlink_dir"
if [ ! -L "$SYMLINK_TMP_DIR/symlink_dir" ]; then
  echo "FAIL: directory-symlink fixture was not created" >&2
  exit 1
fi
if symlink_dir_output="$(bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "$SYMLINK_TMP_DIR/symlink_dir/output.mp4" 2>&1)"; then
  symlink_dir_status=0
else
  symlink_dir_status=$?
fi
if [ "$symlink_dir_status" -eq 0 ]; then
  echo "FAIL: download-reference.sh must abort when output directory is a symlink" >&2
  exit 1
fi
if ! grep -q -F "Output path contains a symbolic-link directory. Aborting" <<< "$symlink_dir_output"; then
  echo "FAIL: download-reference.sh must report output directory symlink detection" >&2
  printf '%s\n' "$symlink_dir_output" >&2
  exit 1
fi
if [ ! -L "$SYMLINK_TMP_DIR/symlink_dir" ] \
  || [ "$(cat "$SYMLINK_TMP_DIR/real_dir/output.mp4")" != "dummy" ]; then
  echo "FAIL: rejected directory symlink must remain intact without changing its target" >&2
  exit 1
fi

rm -rf "$SYMLINK_TMP_DIR"
echo "PASS: download-reference.sh properly aborts on symlinked paths"
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
  if [ -n "${YT_DLP_SWAP_DESTINATION:-}" ]; then
    rm -f -- "$YT_DLP_SWAP_DESTINATION"
    ln -s -- "${YT_DLP_SWAP_TARGET:?}" "$YT_DLP_SWAP_DESTINATION"
  fi
  mkdir -p -- "$(dirname -- "$output")"
  : > "$output"
fi
EOF
chmod +x "$TMP_DIR/yt-dlp"

echo "=== Testing intermediate parent symlink prevention ==="
mkdir -p -- "$TMP_DIR/real-parent"
ln -s -- "$TMP_DIR/real-parent" "$TMP_DIR/linked-parent"
if intermediate_output="$(
  PATH="$TMP_DIR:$PATH" \
  YT_DLP_ARGS_FILE="$TMP_DIR/intermediate-yt-dlp.args" \
    bash "$SCRIPT_DIR/download-reference.sh" \
      "dummy_url" "$TMP_DIR/linked-parent/nested/reference.mp4" 2>&1
)"; then
  intermediate_status=0
else
  intermediate_status=$?
fi
if [ "$intermediate_status" -eq 0 ]; then
  echo "FAIL: download-reference.sh must reject a symlink in any parent component" >&2
  exit 1
fi
if [ -e "$TMP_DIR/real-parent/nested/reference.mp4" ]; then
  echo "FAIL: intermediate symlink validation must happen before creating or publishing output" >&2
  exit 1
fi
if ! grep -q -F "Output path contains a symbolic-link directory" <<< "$intermediate_output"; then
  echo "FAIL: intermediate symlink rejection must use the stable security diagnostic" >&2
  printf '%s\n' "$intermediate_output" >&2
  exit 1
fi
echo "PASS: intermediate parent symlinks are rejected before publication"
echo "====================================="

echo "=== Testing destination swap cannot overwrite another file ==="
VICTIM_FILE="$TMP_DIR/victim.txt"
SWAP_OUTPUT="$TMP_DIR/swap-output.mp4"
printf '%s' "preserve-me" > "$VICTIM_FILE"
if swap_output="$(
  PATH="$TMP_DIR:$PATH" \
  YT_DLP_ARGS_FILE="$TMP_DIR/swap-yt-dlp.args" \
  YT_DLP_SWAP_DESTINATION="$SWAP_OUTPUT" \
  YT_DLP_SWAP_TARGET="$VICTIM_FILE" \
    bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "$SWAP_OUTPUT" 2>&1
)"; then
  swap_status=0
else
  swap_status=$?
fi
if [ "$swap_status" -eq 0 ]; then
  echo "FAIL: publication must fail closed when the destination changes during download" >&2
  exit 1
fi
if [ "$(cat "$VICTIM_FILE")" != "preserve-me" ]; then
  echo "FAIL: a destination swap must never overwrite the linked target" >&2
  exit 1
fi
if ! grep -q -F "Output destination changed before publication" <<< "$swap_output"; then
  echo "FAIL: destination swap rejection must use the stable security diagnostic" >&2
  printf '%s\n' "$swap_output" >&2
  exit 1
fi
echo "PASS: destination swaps cannot overwrite another file"
echo "====================================="

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
ln -s -- "$(command -v python3)" "$CACHE_HIT_PATH/python3"
printf 'existing-video-payload\n\001\377\n' > "$CACHED_OUTPUT"
cp -- "$CACHED_OUTPUT" "$EXPECTED_CACHED_OUTPUT"

for forbidden_command in yt-dlp brew pip3 pip; do
  if PATH="$CACHE_HIT_PATH" command -v "$forbidden_command" >/dev/null 2>&1; then
    echo "FAIL: cache-hit PATH must exclude $forbidden_command" >&2
    exit 1
  fi
done

if cached_output="$(
  PATH="$CACHE_HIT_PATH" \
  YT_DLP_ARGS_FILE="$CACHED_ARGS_FILE" \
    /bin/bash "$SCRIPT_DIR/download-reference.sh" \
      "https://example.invalid/cached-video" "$CACHED_OUTPUT" 2>&1
)"; then
  cached_status=0
else
  cached_status=$?
fi

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
if missing_download_output="$(bash "$SCRIPT_DIR/download-reference.sh" 2>&1)"; then
  missing_download_status=0
else
  missing_download_status=$?
fi
if [ "$missing_download_status" -eq 0 ] \
  || ! grep -q "Error: Missing required argument(s)." <<< "$missing_download_output"; then
  echo "FAIL: download-reference.sh did not print explicit error message" >&2
  exit 1
fi
echo "PASS: download-reference.sh prints explicit error message"
echo "====================================="

echo "=== Testing usage block for invalid arguments ==="
if invalid_model_output="$(bash "$SCRIPT_DIR/transcribe.sh" "dummy.wav" "invalid_model" 2>&1)"; then
  invalid_model_status=0
else
  invalid_model_status=$?
fi
if [ "$invalid_model_status" -eq 0 ] \
  || ! grep -q "Usage: transcribe.sh <audio_path> \[model\]" <<< "$invalid_model_output"; then
  echo "FAIL: transcribe.sh did not print usage block for invalid model" >&2
  exit 1
fi
echo "PASS: transcribe.sh prints usage block for invalid model"

if invalid_frames_output="$(bash "$SCRIPT_DIR/extract-frames.sh" "dummy.mp4" "dummy_dir" "invalid_num" 2>&1)"; then
  invalid_frames_status=0
else
  invalid_frames_status=$?
fi
if [ "$invalid_frames_status" -eq 0 ] \
  || ! grep -q "Usage: extract-frames.sh <video_path> <output_dir> \[num_frames\]" <<< "$invalid_frames_output"; then
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
help_output="$(bash "$SCRIPT_DIR/download-reference.sh" "dummy_url" "--help")"
if ! grep -q "Download Reference Video Script" <<< "$help_output"; then
  echo "FAIL: download-reference.sh did not recognize --help as second argument" >&2
  exit 1
fi
echo "PASS: download-reference.sh recognizes --help at any position"
echo "====================================="

echo "=== Testing usage block on file not found error ==="
if missing_audio_output="$(bash "$SCRIPT_DIR/transcribe.sh" "dummy_nonexistent.wav" "base" 2>&1)"; then
  missing_audio_status=0
else
  missing_audio_status=$?
fi
if [ "$missing_audio_status" -eq 0 ] \
  || ! grep -q "Usage: transcribe.sh <audio_path> \[model\]" <<< "$missing_audio_output"; then
  echo "FAIL: transcribe.sh did not print usage block for file not found error" >&2
  exit 1
fi
echo "PASS: transcribe.sh prints usage block for file not found error"
echo "====================================="

echo "=== Testing ffprobe dependency preflight ==="
DUMMY_VIDEO="$TMP_DIR/ffprobe-preflight.mp4"
: > "$DUMMY_VIDEO"
if ffprobe_output="$(
  FFMPEG="/bin/true" \
  FFPROBE="$TMP_DIR/missing-ffprobe" \
    bash "$SCRIPT_DIR/extract-frames.sh" "$DUMMY_VIDEO" "$TMP_DIR/ffprobe-output" 12 2>&1
)"; then
  ffprobe_status=0
else
  ffprobe_status=$?
fi
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

if extract_example_output="$(bash "$SCRIPT_DIR/extract-frames.sh" "dummy" "dummy" "invalid" 2>&1)"; then :; fi
assert_colored_example "$extract_example_output" "extract-frames.sh invalid num_frames output"

download_help_output="$(bash "$SCRIPT_DIR/download-reference.sh" --help 2>&1)"
assert_colored_example "$download_help_output" "download-reference.sh --help output"
if download_error_output="$(bash "$SCRIPT_DIR/download-reference.sh" 2>&1)"; then :; fi
assert_colored_example "$download_error_output" "download-reference.sh error output"

transcribe_help_output="$(bash "$SCRIPT_DIR/transcribe.sh" --help 2>&1)"
assert_colored_example "$transcribe_help_output" "transcribe.sh --help output"
if transcribe_error_output="$(bash "$SCRIPT_DIR/transcribe.sh" "dummy_nonexistent.wav" base 2>&1)"; then :; fi
assert_colored_example "$transcribe_error_output" "transcribe.sh error output"

echo "PASS: all three scripts keep Cyan Example highlighting and reset terminal color"
echo "====================================="
