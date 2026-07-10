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
