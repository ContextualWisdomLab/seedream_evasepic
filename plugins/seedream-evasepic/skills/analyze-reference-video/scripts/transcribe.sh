#!/bin/bash
# Transcribe audio from a reference video using OpenAI Whisper.
# Usage: transcribe.sh <audio_path> [model]
#
# Models: tiny / base / small / medium / large  (default: base)
# Output: <audio_path>.txt and <audio_path>.segments.json

set -euo pipefail

AUDIO="${1:-}"
MODEL="${2:-base}"

if [ -z "$AUDIO" ]; then
  echo "Usage: $0 <audio_path> [model]" >&2
  echo "  Models: tiny / base / small / medium / large (default: base)" >&2
  exit 2
fi

if [ ! -f "$AUDIO" ]; then
  echo "Error: audio file not found: $AUDIO" >&2
  exit 1
fi

# Try whisper CLI first
if command -v whisper >/dev/null 2>&1; then
  echo "Transcribing with whisper CLI (model: $MODEL)..."
  OUT_DIR="$(dirname "$AUDIO")"
  whisper "$AUDIO" \
    --model "$MODEL" \
    --output_format txt \
    --output_format json \
    --output_dir "$OUT_DIR" \
    --verbose False
  echo "Transcript saved to $OUT_DIR/$(basename "${AUDIO%.*}").txt"
  exit 0
fi

# Fallback to Python inline
if command -v python3 >/dev/null 2>&1; then
  echo "whisper CLI not found. Trying Python whisper module..."
  python3 -c "import whisper" 2>/dev/null || {
    echo "whisper Python module not installed." >&2
    echo "Install with: pip3 install openai-whisper" >&2
    echo "" >&2
    echo "Alternatively, ask the user to paste the dialogue manually and skip this step." >&2
    exit 1
  }

  python3 - "$AUDIO" "$MODEL" <<'PYEOF'
import whisper, json, os, sys
audio = sys.argv[1]
model_name = sys.argv[2]
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

echo "Neither whisper CLI nor python3 available." >&2
echo "Install one of:" >&2
echo "  brew install openai-whisper     (macOS, installs CLI)" >&2
echo "  pip install openai-whisper      (any OS, requires python3)" >&2
exit 1
