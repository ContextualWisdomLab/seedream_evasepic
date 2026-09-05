#!/bin/bash

set -euo pipefail

SCRIPT_DIR="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
# shellcheck source=plugins/seedream-evasepic/skills/analyze-reference-video/scripts/file-size.sh
. "$SCRIPT_DIR/file-size.sh"

assert_size() {
  local bytes="$1"
  local expected="$2"
  local actual
  actual="$(format_file_size_bytes "$bytes")"
  if [ "$actual" != "$expected" ]; then
    printf 'FAIL: %s bytes formatted as %q; expected %q\n' "$bytes" "$actual" "$expected" >&2
    exit 1
  fi
}

assert_size 0 "0 bytes"
assert_size 1023 "1023 bytes"
assert_size 1024 "1.0 KiB (1024 bytes)"
assert_size 1536 "1.5 KiB (1536 bytes)"
assert_size 1048576 "1.0 MiB (1048576 bytes)"
assert_size 1572864 "1.5 MiB (1572864 bytes)"

if format_file_size_bytes "1.5" >/dev/null 2>&1; then
  echo "FAIL: non-integer byte counts must be rejected" >&2
  exit 1
fi

echo "PASS: file-size formatter preserves byte truth and IEC binary-unit labels"
