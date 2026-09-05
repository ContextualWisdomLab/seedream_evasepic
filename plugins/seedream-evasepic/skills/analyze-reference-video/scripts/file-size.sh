#!/bin/bash

# Format an exact non-negative byte count with IEC binary units while retaining
# the source byte count for unambiguous diagnostics and copy/paste use.
format_file_size_bytes() {
  local bytes="${1:-}"
  local unit whole remainder tenth

  if [[ ! "$bytes" =~ ^[0-9]+$ ]]; then
    return 2
  fi

  if [ "$bytes" -ge 1048576 ]; then
    unit=1048576
    whole=$((bytes / unit))
    remainder=$((bytes % unit))
    tenth=$(((remainder * 10 + unit / 2) / unit))
    if [ "$tenth" -eq 10 ]; then
      whole=$((whole + 1))
      tenth=0
    fi
    printf '%d.%d MiB (%d bytes)' "$whole" "$tenth" "$bytes"
  elif [ "$bytes" -ge 1024 ]; then
    unit=1024
    whole=$((bytes / unit))
    remainder=$((bytes % unit))
    tenth=$(((remainder * 10 + unit / 2) / unit))
    if [ "$tenth" -eq 10 ]; then
      whole=$((whole + 1))
      tenth=0
    fi
    printf '%d.%d KiB (%d bytes)' "$whole" "$tenth" "$bytes"
  else
    printf '%d bytes' "$bytes"
  fi
}
