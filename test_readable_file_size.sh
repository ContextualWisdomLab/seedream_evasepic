#!/bin/bash
# Verify readable file-size output at the real download-reference CLI boundary.

set -euo pipefail

SCRIPT="plugins/seedream-evasepic/skills/analyze-reference-video/scripts/download-reference.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

cat > "$TMP_DIR/yt-dlp" <<'STUB'
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
[ -n "$output" ] || exit 2
mkdir -p -- "${output%/*}"
printf '%*s' "${FAKE_SIZE_BYTES:?}" '' > "$output"
STUB
chmod +x "$TMP_DIR/yt-dlp"

# A successful download must not gain an undeclared awk dependency merely to render size text.
cat > "$TMP_DIR/awk" <<'STUB'
#!/bin/bash
exit 97
STUB
chmod +x "$TMP_DIR/awk"

run_case() {
  local size_bytes="$1"
  local expected="$2"
  local output_path="$TMP_DIR/reference-${size_bytes}.mp4"
  local cli_output actual_size

  cli_output="$(
    PATH="$TMP_DIR:$PATH" \
    FAKE_SIZE_BYTES="$size_bytes" \
      bash "$SCRIPT" "https://example.invalid/${size_bytes}" "$output_path" 2>&1
  )"

  if ! grep -Fq -- "Size: $expected" <<< "$cli_output"; then
    printf 'FAIL: %s bytes did not render as %s\n%s\n' "$size_bytes" "$expected" "$cli_output" >&2
    exit 1
  fi

  actual_size="$(wc -c < "$output_path")"
  actual_size="${actual_size//[[:space:]]/}"
  if [ "$actual_size" != "$size_bytes" ]; then
    printf 'FAIL: fixture expected %s bytes but wrote %s\n' "$size_bytes" "$actual_size" >&2
    exit 1
  fi
}

run_case 0 "0 B"
run_case 1023 "1023 B"
run_case 1024 "1.0 KiB"
run_case 1536 "1.5 KiB"
run_case 1048576 "1.0 MiB"

printf 'PASS: download-reference.sh renders binary units without an awk runtime dependency\n'
