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

echo "=== Testing yt-dlp argument separator ==="
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

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
  mkdir -p "$(dirname "$output")"
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

# shellcheck disable=SC2016 # Match the literal source expression, not shell-expanded values.
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
if ! grep -q '\\033\[0;32mTranscript' "$SCRIPT_DIR/transcribe.sh"; then
  echo "FAIL: transcribe.sh Python inline script does not contain ANSI color for 'Transcript'" >&2
  exit 1
fi
echo "PASS: transcribe.sh Python inline script contains ANSI color codes"
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

echo "=== Testing ANSI escape sequence injection prevention ==="
INJECTED_CLEAR_SCREEN="$(printf '\033[2J')"
MALICIOUS_DOWNLOAD_URL="https://example.invalid/"$'\033[2J'
MALICIOUS_DOWNLOAD_OUTPUT="$TMP_DIR/download"$'\033[2J'".mp4"
DOWNLOAD_OUTPUT_LOG="$TMP_DIR/download-terminal-output.log"
PATH="$TMP_DIR:$PATH" \
YT_DLP_ARGS_FILE="$ARGS_FILE" \
  bash "$SCRIPT_DIR/download-reference.sh" \
    "$MALICIOUS_DOWNLOAD_URL" "$MALICIOUS_DOWNLOAD_OUTPUT" > "$DOWNLOAD_OUTPUT_LOG" 2>&1

if grep -F -q "$INJECTED_CLEAR_SCREEN" "$DOWNLOAD_OUTPUT_LOG"; then
  echo "FAIL: download-reference.sh emitted an untrusted ANSI escape" >&2
  exit 1
fi

if ! grep -F -q '\E[2J' "$DOWNLOAD_OUTPUT_LOG"; then
  echo "FAIL: download-reference.sh did not render the control byte safely" >&2
  exit 1
fi

cat > "$TMP_DIR/ffprobe" <<'EOF'
#!/bin/bash
printf '%s\n' \
  'duration=1' \
  'width=1' \
  'height=1' \
  'r_frame_rate=1/1' \
  'codec_type=video'
EOF

cat > "$TMP_DIR/ffmpeg" <<'EOF'
#!/bin/bash
set -eu
: > "${FAKE_FRAME_OUTPUT_DIR:?}/frame_001.jpg"
EOF

chmod +x "$TMP_DIR/ffprobe" "$TMP_DIR/ffmpeg"
VIDEO_FILE="$TMP_DIR/video.mp4"
: > "$VIDEO_FILE"
MALICIOUS_OUT_DIR="$TMP_DIR/output"$'\033[2J'"spoof"
OUTPUT_LOG="$TMP_DIR/terminal-output.log"

FFMPEG="$TMP_DIR/ffmpeg" \
FFPROBE="$TMP_DIR/ffprobe" \
FAKE_FRAME_OUTPUT_DIR="$MALICIOUS_OUT_DIR" \
  bash "$SCRIPT_DIR/extract-frames.sh" \
    "$VIDEO_FILE" "$MALICIOUS_OUT_DIR" 1 > "$OUTPUT_LOG" 2>&1

if grep -F -q "$INJECTED_CLEAR_SCREEN" "$OUTPUT_LOG"; then
  echo "FAIL: extract-frames.sh evaluated an untrusted ANSI escape" >&2
  exit 1
fi

if ! grep -F -q '\E[2Jspoof' "$OUTPUT_LOG"; then
  echo "FAIL: extract-frames.sh did not render the control byte safely" >&2
  exit 1
fi

for SCRIPT in download-reference.sh extract-frames.sh transcribe.sh; do
  MALICIOUS_SCRIPT="$TMP_DIR/${SCRIPT}"$'\033[2J'
  SCRIPT_OUTPUT_LOG="$TMP_DIR/${SCRIPT}.terminal-output.log"
  ln -s "$(pwd)/$SCRIPT_DIR/$SCRIPT" "$MALICIOUS_SCRIPT"
  bash "$MALICIOUS_SCRIPT" --help > "$SCRIPT_OUTPUT_LOG" 2>&1

  if grep -F -q "$INJECTED_CLEAR_SCREEN" "$SCRIPT_OUTPUT_LOG"; then
    echo "FAIL: $SCRIPT evaluated an ANSI escape from its invocation path" >&2
    exit 1
  fi

  if ! grep -F -q '\E[2J' "$SCRIPT_OUTPUT_LOG"; then
    echo "FAIL: $SCRIPT did not render its invocation path safely" >&2
    exit 1
  fi
done

PYTHON3_BIN="$(python3 -c 'import sys; print(sys.executable)')"
ln -s "$PYTHON3_BIN" "$TMP_DIR/python3"
cat > "$TMP_DIR/whisper.py" <<'PYEOF'
class FakeModel:
    def transcribe(self, _audio):
        return {"text": "ok", "language": "en", "segments": []}


def load_model(_name):
    return FakeModel()
PYEOF

MALICIOUS_AUDIO="$TMP_DIR/audio"$'\033[2J'".wav"
PYTHON_OUTPUT_LOG="$TMP_DIR/python-terminal-output.log"
: > "$MALICIOUS_AUDIO"
PATH="$TMP_DIR" \
PYTHONPATH="$TMP_DIR" \
  "$BASH" "$SCRIPT_DIR/transcribe.sh" \
    "$MALICIOUS_AUDIO" base > "$PYTHON_OUTPUT_LOG" 2>&1

if grep -F -q "$INJECTED_CLEAR_SCREEN" "$PYTHON_OUTPUT_LOG"; then
  echo "FAIL: transcribe.sh Python fallback emitted an untrusted ANSI escape" >&2
  exit 1
fi

if ! grep -F -q '\x1b[2J' "$PYTHON_OUTPUT_LOG"; then
  echo "FAIL: transcribe.sh Python fallback did not render the control byte safely" >&2
  exit 1
fi

echo "PASS: shell and Python outputs escape untrusted control bytes"
echo "====================================="
