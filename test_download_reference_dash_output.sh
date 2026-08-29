#!/bin/bash
# Regression: a dash-prefixed relative output name must remain a valid exact final pathname.

set -euo pipefail

ROOT_DIR="$(pwd -P)"
SCRIPT="$ROOT_DIR/plugins/seedream-evasepic/skills/analyze-reference-video/scripts/download-reference.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

MOCK_BIN="$TMP_DIR/bin"
mkdir -p -- "$MOCK_BIN"
cat > "$MOCK_BIN/yt-dlp" <<'EOF'
#!/bin/bash
set -euo pipefail

output=""
while [ "$#" -gt 0 ]; do
  if [ "$1" = "-o" ]; then
    shift
    output="${1:-}"
    break
  fi
  shift
done

if [ -z "$output" ]; then
  echo "mock yt-dlp did not receive -o" >&2
  exit 2
fi

mkdir -p -- "$(dirname -- "$output")"
printf 'dash-prefixed-output-bytes\n' > "$output"
EOF
chmod +x "$MOCK_BIN/yt-dlp"

DASH_OUTPUT="-reference.mp4"
if ! (
  cd "$TMP_DIR"
  PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" \
    "https://example.invalid/dash-output" "$DASH_OUTPUT" >/dev/null
); then
  echo "FAIL: dash-prefixed relative output must publish successfully" >&2
  exit 1
fi

if [ ! -f "$TMP_DIR/$DASH_OUTPUT" ]; then
  echo "FAIL: dash-prefixed relative output was not published at the requested path" >&2
  exit 1
fi
if [ "$(cat -- "$TMP_DIR/$DASH_OUTPUT")" != "dash-prefixed-output-bytes" ]; then
  echo "FAIL: dash-prefixed relative output did not preserve downloaded bytes" >&2
  exit 1
fi

printf 'PASS: dash-prefixed relative output publishes to the exact requested pathname\n'
