#!/bin/bash
set -euo pipefail

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

mkdir -p -- "$TMP_DIR/bin"
VICTIM="$TMP_DIR/victim.txt"
OUTPUT="$TMP_DIR/reference.mp4"
ARGS_FILE="$TMP_DIR/yt-dlp.args"
printf 'protected-victim\n' > "$VICTIM"

cat > "$TMP_DIR/bin/yt-dlp" <<'EOF'
#!/bin/bash
set -euo pipefail
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
[ -n "$output" ] || exit 97

# Deterministically model the caller-owned final path becoming a symlink after
# admission but while the downloader still owns its output handle/path.
ln -s -- "${RACE_VICTIM:?}" "${RACE_OUTPUT:?}"
printf 'downloaded-artifact\n' > "$output"
EOF
chmod +x "$TMP_DIR/bin/yt-dlp"

set +e
PATH="$TMP_DIR/bin:$PATH" \
YT_DLP_ARGS_FILE="$ARGS_FILE" \
RACE_OUTPUT="$OUTPUT" \
RACE_VICTIM="$VICTIM" \
  bash "$SCRIPT_DIR/download-reference.sh" \
    "https://example.invalid/race" "$OUTPUT" >/dev/null 2>&1
status=$?
set -e

if ! grep -Fxq 'protected-victim' "$VICTIM"; then
  echo "FAIL: downloader followed a symlink introduced after the preflight check" >&2
  exit 1
fi

captured_output="$(awk 'previous == "-o" { print; exit } { previous = $0 }' "$ARGS_FILE")"
if [ -z "$captured_output" ] || [ "$captured_output" = "$OUTPUT" ]; then
  echo "FAIL: untrusted downloader must never receive the caller-owned final path" >&2
  cat "$ARGS_FILE" >&2
  exit 1
fi

if [ "$status" -ne 0 ]; then
  echo "FAIL: safe atomic publication should replace the raced final symlink without touching its target" >&2
  exit 1
fi
if [ -L "$OUTPUT" ] || [ ! -f "$OUTPUT" ]; then
  echo "FAIL: final output must be a regular published artifact, not the raced symlink" >&2
  exit 1
fi
if ! grep -Fxq 'downloaded-artifact' "$OUTPUT"; then
  echo "FAIL: safely downloaded artifact was not published to the requested output" >&2
  exit 1
fi

echo "PASS: downloader writes a private staging path and publication does not follow raced final symlinks"
