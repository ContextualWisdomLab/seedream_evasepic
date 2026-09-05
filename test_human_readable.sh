#!/bin/bash
human_readable_size() {
  local size=$1
  awk -v size="$size" 'BEGIN {
    if (size >= 1048576) printf "%.2f MB", size/1048576
    else if (size >= 1024) printf "%.2f KB", size/1024
    else printf "%d bytes", size
  }'
}
FILE_SIZE_BYTES=1536000
HUMAN_READABLE="$(human_readable_size "$FILE_SIZE_BYTES")"
echo "Size: $HUMAN_READABLE"
