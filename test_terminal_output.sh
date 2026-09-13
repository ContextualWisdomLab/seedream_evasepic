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

printf '=== Testing exhaustive C0 and C1 control neutralization ===\n'
exhaustive_input=""
exhaustive_expected=""

# Generate all C0 controls (0x01..0x1F)
exhaustive_input+=$'\001'
exhaustive_expected+='\x01'
exhaustive_input+=$'\002'
exhaustive_expected+='\x02'
exhaustive_input+=$'\003'
exhaustive_expected+='\x03'
exhaustive_input+=$'\004'
exhaustive_expected+='\x04'
exhaustive_input+=$'\005'
exhaustive_expected+='\x05'
exhaustive_input+=$'\006'
exhaustive_expected+='\x06'
exhaustive_input+=$'\007'
exhaustive_expected+='\x07'
exhaustive_input+=$'\010'
exhaustive_expected+='\x08'
exhaustive_input+=$'\011'
exhaustive_expected+='\x09'
exhaustive_input+=$'\012'
exhaustive_expected+='\x0A'
exhaustive_input+=$'\013'
exhaustive_expected+='\x0B'
exhaustive_input+=$'\014'
exhaustive_expected+='\x0C'
exhaustive_input+=$'\015'
exhaustive_expected+='\x0D'
exhaustive_input+=$'\016'
exhaustive_expected+='\x0E'
exhaustive_input+=$'\017'
exhaustive_expected+='\x0F'
exhaustive_input+=$'\020'
exhaustive_expected+='\x10'
exhaustive_input+=$'\021'
exhaustive_expected+='\x11'
exhaustive_input+=$'\022'
exhaustive_expected+='\x12'
exhaustive_input+=$'\023'
exhaustive_expected+='\x13'
exhaustive_input+=$'\024'
exhaustive_expected+='\x14'
exhaustive_input+=$'\025'
exhaustive_expected+='\x15'
exhaustive_input+=$'\026'
exhaustive_expected+='\x16'
exhaustive_input+=$'\027'
exhaustive_expected+='\x17'
exhaustive_input+=$'\030'
exhaustive_expected+='\x18'
exhaustive_input+=$'\031'
exhaustive_expected+='\x19'
exhaustive_input+=$'\032'
exhaustive_expected+='\x1A'
exhaustive_input+=$'\033'
exhaustive_expected+='\x1B'
exhaustive_input+=$'\034'
exhaustive_expected+='\x1C'
exhaustive_input+=$'\035'
exhaustive_expected+='\x1D'
exhaustive_input+=$'\036'
exhaustive_expected+='\x1E'
exhaustive_input+=$'\037'
exhaustive_expected+='\x1F'

# Generate DEL (0x7F)
exhaustive_input+=$'\177'
exhaustive_expected+='\x7F'

# Generate all C1 controls (U+0080..U+009F)
exhaustive_input+=$'\302\200'
exhaustive_expected+='\u0080'
exhaustive_input+=$'\302\201'
exhaustive_expected+='\u0081'
exhaustive_input+=$'\302\202'
exhaustive_expected+='\u0082'
exhaustive_input+=$'\302\203'
exhaustive_expected+='\u0083'
exhaustive_input+=$'\302\204'
exhaustive_expected+='\u0084'
exhaustive_input+=$'\302\205'
exhaustive_expected+='\u0085'
exhaustive_input+=$'\302\206'
exhaustive_expected+='\u0086'
exhaustive_input+=$'\302\207'
exhaustive_expected+='\u0087'
exhaustive_input+=$'\302\210'
exhaustive_expected+='\u0088'
exhaustive_input+=$'\302\211'
exhaustive_expected+='\u0089'
exhaustive_input+=$'\302\212'
exhaustive_expected+='\u008A'
exhaustive_input+=$'\302\213'
exhaustive_expected+='\u008B'
exhaustive_input+=$'\302\214'
exhaustive_expected+='\u008C'
exhaustive_input+=$'\302\215'
exhaustive_expected+='\u008D'
exhaustive_input+=$'\302\216'
exhaustive_expected+='\u008E'
exhaustive_input+=$'\302\217'
exhaustive_expected+='\u008F'
exhaustive_input+=$'\302\220'
exhaustive_expected+='\u0090'
exhaustive_input+=$'\302\221'
exhaustive_expected+='\u0091'
exhaustive_input+=$'\302\222'
exhaustive_expected+='\u0092'
exhaustive_input+=$'\302\223'
exhaustive_expected+='\u0093'
exhaustive_input+=$'\302\224'
exhaustive_expected+='\u0094'
exhaustive_input+=$'\302\225'
exhaustive_expected+='\u0095'
exhaustive_input+=$'\302\226'
exhaustive_expected+='\u0096'
exhaustive_input+=$'\302\227'
exhaustive_expected+='\u0097'
exhaustive_input+=$'\302\230'
exhaustive_expected+='\u0098'
exhaustive_input+=$'\302\231'
exhaustive_expected+='\u0099'
exhaustive_input+=$'\302\232'
exhaustive_expected+='\u009A'
exhaustive_input+=$'\302\233'
exhaustive_expected+='\u009B'
exhaustive_input+=$'\302\234'
exhaustive_expected+='\u009C'
exhaustive_input+=$'\302\235'
exhaustive_expected+='\u009D'
exhaustive_input+=$'\302\236'
exhaustive_expected+='\u009E'
exhaustive_input+=$'\302\237'
exhaustive_expected+='\u009F'

safe_exhaustive="$(terminal_safe_text "$exhaustive_input")"
if [ "$safe_exhaustive" != "$exhaustive_expected" ]; then
  printf 'FAIL: Exhaustive C0/C1 neutralization failed.\n' >&2
  printf 'Expected: %q\n' "$exhaustive_expected" >&2
  printf 'Got:      %q\n' "$safe_exhaustive" >&2
  exit 1
fi
printf 'PASS: terminal_safe_text strictly neutralizes all 0x01..0x1F, DEL, and U+0080..U+009F\n'


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

printf '=== Testing static terminal-output contract ===\n'
if grep -nE 'printf[[:space:]]+"%b[^\"]*"[^#]*(\$URL|\$OUTPUT|\$VIDEO|\$OUT_DIR|\$MODEL|\$AUDIO)' \
  "$SCRIPT_DIRECTORY/download-reference.sh" \
  "$SCRIPT_DIRECTORY/extract-frames.sh" \
  "$SCRIPT_DIRECTORY/transcribe.sh"; then
  fail 'a user-controlled value is still sent through %b'
fi
if grep -nE 'print\(f?"[^\"]*\{(audio|out_base)' "$SCRIPT_DIRECTORY/transcribe.sh"; then
  fail 'Python fallback still prints a user-controlled path to the terminal'
fi
printf 'PASS: static contract keeps untrusted values out of terminal control sinks\n'
