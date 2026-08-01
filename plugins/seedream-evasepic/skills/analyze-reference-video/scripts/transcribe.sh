#!/bin/bash
# Transcribe audio from a reference video using OpenAI Whisper.
# Usage: transcribe.sh <audio_path> [model]
#
# Models: tiny / base / small / medium / large  (default: base)
# Output: <audio_path>.txt and <audio_path>.segments.json

set -euo pipefail

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

for arg in "$@"; do
  if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
    printf "%b\n" "${GREEN}Transcribe Audio Script${NC}"
    printf "%b\n" "${YELLOW}Usage: ${0##*/} <audio_path> [model]${NC}"
    printf "%b\n" "  Models: tiny / base / small / medium / large (default: base)"
    printf "%b\n" "  Example: ${0##*/} /tmp/audio.wav base"
    exit 0
  fi
done

AUDIO="${1:-}"
MODEL="${2:-base}"

case "$MODEL" in
  tiny|base|small|medium|large) ;;
  *)
    printf "%b%s%b\n" "${RED}Error: Invalid model specified: " "$MODEL" "${NC}" >&2
    printf "%b\n" "${YELLOW}Usage: ${0##*/} <audio_path> [model]${NC}" >&2
    printf "%b\n" "  Models: tiny / base / small / medium / large (default: base)" >&2
    printf "%b\n" "  Example: ${0##*/} /tmp/audio.wav base" >&2
    exit 2
    ;;
esac

if [ -z "$AUDIO" ]; then
  printf "%b\n" "${RED}Error: Missing required argument(s).${NC}" >&2
  printf "%b\n" "${YELLOW}Usage: ${0##*/} <audio_path> [model]${NC}" >&2
  printf "%b\n" "  Models: tiny / base / small / medium / large (default: base)" >&2
  printf "%b\n" "  Example: ${0##*/} /tmp/audio.wav base" >&2
  exit 2
fi

if [ ! -f "$AUDIO" ]; then
  printf "%b%s%b\n" "${RED}Error: audio file not found: " "$AUDIO" "${NC}" >&2
  printf "%b\n" "${YELLOW}Usage: ${0##*/} <audio_path> [model]${NC}" >&2
  printf "%b\n" "  Models: tiny / base / small / medium / large (default: base)" >&2
  printf "%b\n" "  Example: ${0##*/} /tmp/audio.wav base" >&2
  exit 1
fi

# Try whisper CLI first
if command -v whisper >/dev/null 2>&1; then
  printf "%b%s%b\n" "${CYAN}Transcribing with whisper CLI (model: " "$MODEL)..." "${NC}"
  OUT_DIR="${AUDIO%/*}"
  [ "$OUT_DIR" = "$AUDIO" ] && OUT_DIR="."
  [ -z "$OUT_DIR" ] && OUT_DIR="/"
  whisper \
    --model "$MODEL" \
    --output_format txt \
    --output_format json \
    --output_dir "$OUT_DIR" \
    --verbose False \
    -- "$AUDIO"
  AUDIO_BASE="${AUDIO%.*}"
  printf "%b%s%b\n" "${GREEN}Transcript saved to " "$OUT_DIR/${AUDIO_BASE##*/}.txt" "${NC}"
  exit 0
fi

# Fallback to Python inline
if command -v python3 >/dev/null 2>&1; then
  printf "%b\n" "${YELLOW}whisper CLI not found. Trying Python whisper module...${NC}"
  # Optimization: Use find_spec instead of full import to check module availability (~3s faster)
  python3 -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('whisper') else 1)" 2>/dev/null || {
    printf "%b\n" "${RED}Error: whisper Python module not installed.${NC}" >&2
    printf "%b\n" "${CYAN}Install with: pip3 install openai-whisper${NC}" >&2
    printf "\n" >&2
    printf "%b\n" "${CYAN}Alternatively, ask the user to paste the dialogue manually and skip this step.${NC}" >&2
    exit 1
  }

  export AUDIO_PATH="$AUDIO"
  export WHISPER_MODEL="$MODEL"
  python3 <<'PYEOF'
import whisper, json, os, sys
audio = os.environ.get("AUDIO_PATH")
model_name = os.environ.get("WHISPER_MODEL")
out_base = os.path.splitext(audio)[0]

print(f"\033[0;36mLoading whisper model: {model_name}...\033[0m")
model = whisper.load_model(model_name)
print(f"\033[0;36mTranscribing {audio}...\033[0m")
result = model.transcribe(audio)

# Write plain text
with open(out_base + ".txt", "w") as f:
    f.write(result["text"])

# Write per-segment JSON with timestamps
with open(out_base + ".segments.json", "w") as f:
    json.dump({
        "language": result.get("language", ""),
        "text": result["text"],
        "segments": [
            {"start": s["start"], "end": s["end"], "text": s["text"]}
            for s in result.get("segments", [])
        ]
    }, f, ensure_ascii=False, indent=2)

print(f"\033[0;32mTranscript: {out_base}.txt\033[0m")
print(f"\033[0;32mSegments:   {out_base}.segments.json\033[0m")
print(f"\033[0;32mLanguage detected: {result.get('language', 'unknown')}\033[0m")
PYEOF

  exit 0
fi

printf "%b\n" "${RED}Error: Neither whisper CLI nor python3 available.${NC}" >&2
printf "%b\n" "${CYAN}Install one of:${NC}" >&2
printf "%b\n" "${CYAN}  brew install openai-whisper     (macOS, installs CLI)${NC}" >&2
printf "%b\n" "${CYAN}  pip install openai-whisper      (any OS, requires python3)${NC}" >&2
exit 1
