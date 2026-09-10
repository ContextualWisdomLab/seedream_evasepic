#!/bin/bash
# Regression for the final publication boundary in download-reference.sh.

set -euo pipefail

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

cat > "$TMP_DIR/yt-dlp" <<'EOF'
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
if [ "${YT_DLP_EMPTY_RESULT:-0}" = "1" ]; then
  : > "$output"
  exit 0
fi

# Simulate an attacker replacing the caller-visible final path after the
# script's preflight check but while the download is in progress.
rm -f -- "${YT_DLP_ATTACK_OUTPUT:?}"
ln -s -- "${YT_DLP_ATTACK_TARGET:?}" "${YT_DLP_ATTACK_OUTPUT:?}"
printf 'downloaded-video\n' > "$output"
EOF
chmod +x "$TMP_DIR/yt-dlp"

OUTPUT="$TMP_DIR/reference.mp4"
ATTACK_TARGET="$TMP_DIR/protected-target.txt"
EXPECTED_TARGET="$TMP_DIR/protected-target.expected"
printf 'must-remain-unchanged\n' > "$ATTACK_TARGET"
cp -- "$ATTACK_TARGET" "$EXPECTED_TARGET"

PATH="$TMP_DIR:$PATH" \
YT_DLP_ATTACK_OUTPUT="$OUTPUT" \
YT_DLP_ATTACK_TARGET="$ATTACK_TARGET" \
  bash "$SCRIPT_DIR/download-reference.sh" \
    "https://example.invalid/race-video" "$OUTPUT" >/dev/null

if ! cmp -s -- "$EXPECTED_TARGET" "$ATTACK_TARGET"; then
  echo "FAIL: a late final-path symlink swap modified the symlink target" >&2
  exit 1
fi
if [ -L "$OUTPUT" ] || [ ! -f "$OUTPUT" ]; then
  echo "FAIL: successful publication must replace the raced symlink with a regular artifact" >&2
  exit 1
fi
if ! grep -q -F 'downloaded-video' "$OUTPUT"; then
  echo "FAIL: the downloaded artifact was not published at the requested output path" >&2
  exit 1
fi

echo "PASS: final publication replaces a raced symlink without following its target"

ZERO_OUTPUT="$TMP_DIR/zero-byte-reference.mp4"
PATH="$TMP_DIR:$PATH" \
YT_DLP_EMPTY_RESULT=1 \
  bash "$SCRIPT_DIR/download-reference.sh" \
    "https://example.invalid/zero-byte-video" "$ZERO_OUTPUT" >/dev/null

if [ ! -f "$ZERO_OUTPUT" ] || [ -L "$ZERO_OUTPUT" ] || [ -s "$ZERO_OUTPUT" ]; then
  echo "FAIL: a successful zero-byte regular yt-dlp artifact must retain the pre-repair publication contract" >&2
  exit 1
fi

echo "PASS: security staging does not redefine successful zero-byte artifact validity"
