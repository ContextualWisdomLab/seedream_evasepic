#!/bin/bash
# Verify that actual terminal-control bytes in user-controlled values are rendered visibly.

set -euo pipefail

SCRIPT_DIRECTORY="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
# shellcheck source=plugins/seedream-evasepic/skills/analyze-reference-video/scripts/terminal-output.sh
. "$SCRIPT_DIRECTORY/terminal-output.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_no_ascii_control() {
  local value="$1"
  local label="$2"
  local code octal control

  for code in {1..31}; do
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\${octal}"
    if [[ "$value" == *"$control"* ]]; then
      fail "$label retained ASCII control byte 0x$(printf '%02X' "$code")"
    fi
  done
  if [[ "$value" == *$'\177'* ]]; then
    fail "$label retained DEL"
  fi
}

assert_neutralized_file() {
  local output_file="$1"
  local label="$2"
  local attacker_sequence=$'\033[31mPWNED'

  if LC_ALL=C grep -Fq -- "$attacker_sequence" "$output_file"; then
    fail "$label emitted the attacker-controlled ANSI sequence"
  fi
  if ! grep -Fq -- '\x1B[31mPWNED\x1B[0m\x0AFORGED\x0DLINE' "$output_file"; then
    printf '%s output was:\n' "$label" >&2
    cat "$output_file" >&2
    fail "$label did not preserve the malicious value as visible escaped text"
  fi
}

printf '=== Testing terminal_safe_text control neutralization ===\n'
malicious_value=$'safe\033[31mPWNED\033[0m\nFORGED\rLINE\tBELL\007'
malicious_value+=$'\302\233CSI\342\200\256RTL\342\200\250NEXT'
safe_value="$(terminal_safe_text "$malicious_value")"
assert_no_ascii_control "$safe_value" 'terminal_safe_text'
[[ "$safe_value" != *$'\302\233'* ]] || fail 'terminal_safe_text retained Unicode C1 CSI'
[[ "$safe_value" != *$'\342\200\256'* ]] || fail 'terminal_safe_text retained RIGHT-TO-LEFT OVERRIDE'
[[ "$safe_value" != *$'\342\200\250'* ]] || fail 'terminal_safe_text retained Unicode LINE SEPARATOR'
[[ "$safe_value" == *'\x1B[31mPWNED\x1B[0m\x0AFORGED\x0DLINE\x09BELL\x07'* ]] || fail 'C0 controls were not rendered visibly'
[[ "$safe_value" == *'\u009BCSI\u202ERTL\u2028NEXT'* ]] || fail 'Unicode controls were not rendered visibly'
printf 'PASS: terminal_safe_text neutralizes actual C0, C1, line, and bidi controls\n'

printf '=== Testing script output with actual ESC and newline bytes ===\n'
temporary_directory="$(mktemp -d)"
trap 'rm -rf -- "$temporary_directory"' EXIT

cat >"$temporary_directory/yt-dlp" <<'STUB'
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
if [ -n "$output" ]; then
  mkdir -p -- "${output%/*}"
  : >"$output"
fi
STUB
chmod +x "$temporary_directory/yt-dlp"

script_value=$'safe\033[31mPWNED\033[0m\nFORGED\rLINE'
download_output="$temporary_directory/download.out"
PATH="$temporary_directory:$PATH" \
  bash "$SCRIPT_DIRECTORY/download-reference.sh" \
    "https://example.invalid/$script_value" \
    "$temporary_directory/$script_value.mp4" >"$download_output" 2>&1
assert_neutralized_file "$download_output" 'download-reference.sh'

extract_output="$temporary_directory/extract.out"
FFMPEG=/bin/true \
FFPROBE=/bin/true \
  bash "$SCRIPT_DIRECTORY/extract-frames.sh" \
    "$temporary_directory/$script_value.mp4.missing" \
    "$temporary_directory/frames" >"$extract_output" 2>&1 || true
assert_neutralized_file "$extract_output" 'extract-frames.sh'

transcribe_output="$temporary_directory/transcribe.out"
bash "$SCRIPT_DIRECTORY/transcribe.sh" \
  "$temporary_directory/missing.wav" "$script_value" >"$transcribe_output" 2>&1 || true
assert_neutralized_file "$transcribe_output" 'transcribe.sh model error'

transcribe_path_output="$temporary_directory/transcribe-path.out"
bash "$SCRIPT_DIRECTORY/transcribe.sh" \
  "$temporary_directory/$script_value.wav" base >"$transcribe_path_output" 2>&1 || true
assert_neutralized_file "$transcribe_path_output" 'transcribe.sh audio-path error'
printf 'PASS: all user-facing script values neutralize actual control bytes\n'

printf '=== Testing ffprobe metadata terminal neutralization ===\n'
cat >"$temporary_directory/ffprobe" <<'STUB'
#!/bin/bash
set -euo pipefail
printf 'duration=1\033[31mPWNED\033[0m\n'
printf 'width=1920\033[31mPWNED\033[0m\n'
printf 'height=1080\n'
printf 'r_frame_rate=30/1\033[31mPWNED\033[0m\n'
printf 'codec_type=video\n'
STUB
chmod +x "$temporary_directory/ffprobe"
metadata_video="$temporary_directory/metadata-video.mp4"
: >"$metadata_video"
metadata_output="$temporary_directory/metadata.out"
FFMPEG=/bin/true \
FFPROBE="$temporary_directory/ffprobe" \
  bash "$SCRIPT_DIRECTORY/extract-frames.sh" \
    "$metadata_video" "$temporary_directory/metadata-frames" 3 >"$metadata_output" 2>&1
if LC_ALL=C grep -Fq -- $'\033[31mPWNED' "$metadata_output"; then
  fail 'extract-frames.sh emitted attacker-controlled ANSI from ffprobe metadata'
fi
printf -v ansi_escape '\033'
metadata_text="$(sed "s/${ansi_escape}\\[[0-9;]*m//g" "$metadata_output")"
for expected in \
  'Duration: 1\x1B[31mPWNED\x1B[0ms' \
  'Resolution: 1920\x1B[31mPWNED\x1B[0mx1080' \
  'FPS: 30/1\x1B[31mPWNED\x1B[0m'
do
  if ! grep -Fq -- "$expected" <<<"$metadata_text"; then
    printf '%s\n' 'ffprobe metadata output was:' >&2
    cat "$metadata_output" >&2
    fail "missing visible escaped metadata field: $expected"
  fi
done
printf 'PASS: ffprobe-derived duration, resolution, and FPS stay outside terminal control sinks\n'

normalize_printf_calls() {
  sed -e ':join' -e '/\\$/ { N; s/\\\n/ /; b join; }' "$@"
}
unsafe_percent_b_calls() {
  normalize_printf_calls "$@" |
    awk '
      BEGIN {
        target = "(URL|OUTPUT|VIDEO|OUT_DIR|MODEL|AUDIO|DURATION|RESOLUTION|FPS)"
      }
      /printf[[:space:]]+["'"'"']%b[^"'"'"']*["'"'"']/ &&
        $0 ~ ("\\$\\{?" target "(\\}|[^A-Za-z0-9_])") {
          print
        }
    '
}

printf '=== Testing static detector regression fixtures ===\n'
unsafe_fixture="$temporary_directory/unsafe-percent-b.sh"
cat >"$unsafe_fixture" <<'STUB'
printf "%b\n" "${DURATION}"
printf '%b\n' "$FPS"
printf "%b\n" \
  "${RESOLUTION}"
STUB
detected_fixture="$(unsafe_percent_b_calls "$unsafe_fixture")"
for expected_variable in DURATION FPS RESOLUTION; do
  if ! grep -Fq -- "$expected_variable" <<<"$detected_fixture"; then
    fail "static detector missed unsafe $expected_variable percent-b fixture"
  fi
done
printf 'PASS: static detector covers braced, quoted, and multiline percent-b fixtures\n'

printf '=== Testing static terminal-output contract ===\n'
if unsafe_percent_b_calls \
  "$SCRIPT_DIRECTORY/download-reference.sh" \
  "$SCRIPT_DIRECTORY/extract-frames.sh" \
  "$SCRIPT_DIRECTORY/transcribe.sh"; then
  fail 'a user-controlled value is still sent through %b'
fi
if grep -nE 'print\(f?"[^\"]*\{(audio|out_base)' "$SCRIPT_DIRECTORY/transcribe.sh"; then
  fail 'Python fallback still prints a user-controlled path to the terminal'
fi
printf 'PASS: static contract keeps untrusted values out of terminal control sinks\n'
