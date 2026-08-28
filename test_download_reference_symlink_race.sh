#!/bin/bash
# Regression: an output-path symlink introduced after validation must never redirect download bytes.

set -euo pipefail

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
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

# Simulate the exact TOCTOU window: validation has already completed, then an
# attacker replaces the final output pathname with a symlink before yt-dlp
# writes its output bytes.
rm -f -- "${RACE_OUTPUT:?}"
ln -s -- "${RACE_VICTIM:?}" "$RACE_OUTPUT"
mkdir -p -- "$(dirname -- "$output")"
printf 'downloaded-video-bytes\n' > "$output"
EOF
chmod +x "$MOCK_BIN/yt-dlp"

VICTIM="$TMP_DIR/victim.txt"
OUTPUT="$TMP_DIR/reference.mp4"
printf 'protected-victim-bytes\n' > "$VICTIM"

set +e
race_log="$(
  PATH="$MOCK_BIN:$PATH" \
  RACE_OUTPUT="$OUTPUT" \
  RACE_VICTIM="$VICTIM" \
    bash "$SCRIPT_DIR/download-reference.sh" \
      "https://example.invalid/race-video" "$OUTPUT" 2>&1
)"
race_status=$?
set -e

if [ "$(cat "$VICTIM")" != "protected-victim-bytes" ]; then
  echo "FAIL: output-path race redirected downloaded bytes into the symlink target" >&2
  exit 1
fi

if [ "$race_status" -eq 0 ]; then
  echo "FAIL: output path appearing during download must fail closed" >&2
  exit 1
fi

if ! grep -q -F "Output path changed during download. Remove the unexpected path and retry:" <<< "$race_log"; then
  echo "FAIL: race rejection must tell the caller how to recover safely" >&2
  printf '%s\n' "$race_log" >&2
  exit 1
fi

echo "PASS: symlink swap after validation fails closed without modifying the target"
