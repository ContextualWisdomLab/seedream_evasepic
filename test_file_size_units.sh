#!/bin/bash
"""" 2>/dev/null || true
set -euo pipefail

SCRIPT="plugins/seedream-evasepic/skills/analyze-reference-video/scripts/download-reference.sh"
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
dd if=/dev/zero of="$output" bs=1048576 count=1 status=none
EOF
chmod +x "$TMP_DIR/yt-dlp"

output="$(PATH="$TMP_DIR:$PATH" bash "$SCRIPT" \
  "https://example.invalid/reference" "$TMP_DIR/reference.mp4" 2>&1)"

if ! grep -Fq "Size: 1.00 MiB" <<< "$output"; then
  echo "FAIL: 2^20 bytes must be displayed as 1.00 MiB" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

if grep -Fq "Size: 1.00 MB" <<< "$output"; then
  echo "FAIL: 1024-based scaling must not use decimal SI symbol MB" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

echo "PASS: 1024-based file-size output uses IEC/NIST binary-prefix symbols"
