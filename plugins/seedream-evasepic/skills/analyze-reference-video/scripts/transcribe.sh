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

AUDIO="${1:-}"
MODEL="${2:-base}"

if [ "$AUDIO" = "-h" ] || [ "$AUDIO" = "--help" ]; then
  echo -e "Usage: $0 <audio_path> [model]"
  echo -e "  Models: tiny / base / small / medium / large (default: base)"
  exit 0
fi

if [ -z "$AUDIO" ]; then
  echo -e "${YELLOW}Usage: $0 <audio_path> [model]${NC}" >&2
  echo -e "  Models: tiny / base / small / medium / large (default: base)" >&2
  exit 2
fi

if [ ! -f "$AUDIO" ]; then
  echo -e "${RED}Error: audio file not found: $AUDIO${NC}" >&2
  exit 1
fi

# Try whisper CLI first
if command -v whisper >/dev/null 2>&1; then
  echo -e "${CYAN}Transcribing with whisper CLI (model: $MODEL)...${NC}"
  OUT_DIR="$(dirname "$AUDIO")"
  whisper "$AUDIO" \
    --model "$MODEL" \
    --output_format txt \
    --output_format json \
    --output_dir "$OUT_DIR" \
    --verbose False
  echo -e "${GREEN}Transcript saved to $OUT_DIR/$(basename "${AUDIO%.*}").txt${NC}"
  exit 0
fi

# Fallback to Python inline
if command -v python3 >/dev/null 2>&1; then
  echo -e "${YELLOW}whisper CLI not found. Trying Python whisper module...${NC}"
  python3 -c "import whisper" 2>/dev/null || {
    echo -e "${RED}whisper Python module not installed.${NC}" >&2
    echo -e "Install with: pip3 install openai-whisper" >&2
    echo "" >&2
    echo -e "${CYAN}Alternatively, ask the user to paste the dialogue manually and skip this step.${NC}" >&2
    exit 1
  }

  export AUDIO_PATH="$AUDIO"
  export WHISPER_MODEL="$MODEL"
  python3 <<'PYEOF'
import whisper, json, os, sys
audio = os.environ.get("AUDIO_PATH")
model_name = os.environ.get("WHISPER_MODEL")
out_base = os.path.splitext(audio)[0]

print(f"Loading whisper model: {model_name}...")
model = whisper.load_model(model_name)
print(f"Transcribing {audio}...")
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

print(f"Transcript: {out_base}.txt")
print(f"Segments:   {out_base}.segments.json")
print(f"Language detected: {result.get('language', 'unknown')}")
PYEOF

  exit 0
fi

echo -e "${RED}Neither whisper CLI nor python3 available.${NC}" >&2
echo -e "${CYAN}Install one of:${NC}" >&2
echo -e "  brew install openai-whisper     (macOS, installs CLI)" >&2
echo -e "  pip install openai-whisper      (any OS, requires python3)" >&2
exit 1
