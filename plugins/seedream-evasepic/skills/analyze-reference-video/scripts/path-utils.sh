#!/bin/bash
# Shared path validation helper to prevent path traversal

validate_safe_path() {
  local target_path="$1"
  local safe_base="${2:-${SAFE_BASE_DIR:-/tmp}}"

  # create safe base if not exists
  mkdir -p -- "$safe_base" 2>/dev/null || true

  local abs_target
  local abs_safe

  # Resolve absolute paths with realpath/readlink -f
  if command -v python3 >/dev/null 2>&1; then
    abs_target=$(python3 -c "import os, sys; print(os.path.realpath(sys.argv[1]))" "$target_path")
    abs_safe=$(python3 -c "import os, sys; print(os.path.realpath(sys.argv[1]))" "$safe_base")
  elif command -v realpath >/dev/null 2>&1; then
    # Try realpath, fallback to echo if it fails
    abs_target=$(realpath "$target_path" 2>/dev/null || echo "$target_path")
    abs_safe=$(realpath "$safe_base" 2>/dev/null || echo "$safe_base")
  elif command -v readlink >/dev/null 2>&1 && readlink -f . >/dev/null 2>&1; then
    abs_target=$(readlink -f "$target_path" 2>/dev/null || echo "$target_path")
    abs_safe=$(readlink -f "$safe_base" 2>/dev/null || echo "$safe_base")
  else
    abs_target="$target_path"
    abs_safe="$safe_base"
  fi

  # Check if target is inside safe base
  case "$abs_target" in
    "$abs_safe"*) return 0 ;;
    *)
      printf "\033[0;31mError: Path traversal detected. Path (%s) must be within safe directory (%s)\033[0m\n" "$target_path" "$safe_base" >&2
      return 1
      ;;
  esac
}
