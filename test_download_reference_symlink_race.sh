#!/bin/bash
# Regression: output-path objects introduced after validation must never redirect download bytes.

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

OUTPUT="$TMP_DIR/reference.mp4"
VICTIM_FILE="$TMP_DIR/victim.txt"
printf 'protected-victim-bytes\n' > "$VICTIM_FILE"
VICTIM_DIR="$TMP_DIR/victim-directory"
mkdir -p -- "$VICTIM_DIR"

run_race() {
  local victim="$1"
  local race_log
  local race_status

  rm -f -- "$OUTPUT"
  if race_log="$(
    PATH="$MOCK_BIN:$PATH" \
    RACE_OUTPUT="$OUTPUT" \
    RACE_VICTIM="$victim" \
      bash "$SCRIPT_DIR/download-reference.sh" \
        "https://example.invalid/race-video" "$OUTPUT" 2>&1
  )"; then
    race_status=0
  else
    race_status=$?
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
}

run_race "$VICTIM_FILE"
if [ "$(cat "$VICTIM_FILE")" != "protected-victim-bytes" ]; then
  echo "FAIL: output-path race redirected downloaded bytes into the symlink target" >&2
  exit 1
fi

run_race "$VICTIM_DIR"
if [ -e "$VICTIM_DIR/reference.mp4" ]; then
  echo "FAIL: directory-symlink race published the staged file inside the symlink target" >&2
  exit 1
fi

printf 'PASS: file and directory symlink swaps fail closed without publishing outside the final path\n'
