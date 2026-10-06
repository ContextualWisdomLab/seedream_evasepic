#!/bin/bash
set -euo pipefail

SCRIPT_DIRECTORY="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
source "$SCRIPT_DIRECTORY/terminal-output.sh"

terminal_safe_text_original() {
  local value="${1-}"
  local code octal control replacement

  for code in {1..31}; do
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\${octal}"
    printf -v replacement '\\x%02X' "$code"
    value=${value//"$control"/"$replacement"}
  done
  value=${value//$'\177'/\\x7F}

  for code in {128..159}; do
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\302\\${octal}"
    printf -v replacement '\\u%04X' "$code"
    value=${value//"$control"/"$replacement"}
  done

  value=${value//$'\342\200\213'/\\u200B}
  value=${value//$'\342\200\214'/\\u200C}
  value=${value//$'\342\200\215'/\\u200D}
  value=${value//$'\342\200\216'/\\u200E}
  value=${value//$'\342\200\217'/\\u200F}
  value=${value//$'\342\200\250'/\\u2028}
  value=${value//$'\342\200\251'/\\u2029}
  value=${value//$'\342\200\252'/\\u202A}
  value=${value//$'\342\200\253'/\\u202B}
  value=${value//$'\342\200\254'/\\u202C}
  value=${value//$'\342\200\255'/\\u202D}
  value=${value//$'\342\200\256'/\\u202E}
  value=${value//$'\342\201\240'/\\u2060}
  value=${value//$'\342\201\246'/\\u2066}
  value=${value//$'\342\201\247'/\\u2067}
  value=${value//$'\342\201\250'/\\u2068}
  value=${value//$'\342\201\251'/\\u2069}
  value=${value//$'\330\234'/\\u061C}
  value=${value//$'\357\273\277'/\\uFEFF}

  printf '%s' "$value"
}

terminal_safe_text_new() {
  local value="${1-}"
  local out_var="${2-}"
  local code octal control replacement

  for code in {1..31}; do
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\${octal}"
    printf -v replacement '\\x%02X' "$code"
    value=${value//"$control"/"$replacement"}
  done
  value=${value//$'\177'/\\x7F}

  for code in {128..159}; do
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\302\\${octal}"
    printf -v replacement '\\u%04X' "$code"
    value=${value//"$control"/"$replacement"}
  done

  value=${value//$'\342\200\213'/\\u200B}
  value=${value//$'\342\200\214'/\\u200C}
  value=${value//$'\342\200\215'/\\u200D}
  value=${value//$'\342\200\216'/\\u200E}
  value=${value//$'\342\200\217'/\\u200F}
  value=${value//$'\342\200\250'/\\u2028}
  value=${value//$'\342\200\251'/\\u2029}
  value=${value//$'\342\200\252'/\\u202A}
  value=${value//$'\342\200\253'/\\u202B}
  value=${value//$'\342\200\254'/\\u202C}
  value=${value//$'\342\200\255'/\\u202D}
  value=${value//$'\342\200\256'/\\u202E}
  value=${value//$'\342\201\240'/\\u2060}
  value=${value//$'\342\201\246'/\\u2066}
  value=${value//$'\342\201\247'/\\u2067}
  value=${value//$'\342\201\250'/\\u2068}
  value=${value//$'\342\201\251'/\\u2069}
  value=${value//$'\330\234'/\\u061C}
  value=${value//$'\357\273\277'/\\uFEFF}

  if [[ -n "$out_var" ]]; then
    printf -v "$out_var" '%s' "$value"
  else
    printf '%s' "$value"
  fi
}

echo "=== Regression Test ==="
malicious_value=$'safe\033[31mPWNED\033[0m\nFORGED\rLINE\tBELL\007'
malicious_value+=$'\302\233CSI\342\200\256RTL\342\200\250NEXT'

orig_val="$(terminal_safe_text_original "$malicious_value")"
new_val="$(terminal_safe_text_new "$malicious_value")"

if [ "$orig_val" != "$new_val" ]; then
  echo "FAIL: new subshell behavior differs from original"
  false
fi

terminal_safe_text_new "$malicious_value" test_assigned_val
if [ "$orig_val" != "$test_assigned_val" ]; then
  echo "FAIL: assigned variable behavior differs from original"
  false
fi

echo "All regression tests passed!"

echo "=== Benchmark ==="
ITERATIONS=100

echo "Benchmarking original subshell implementation..."
time for i in $(seq 1 $ITERATIONS); do
  val="$(terminal_safe_text_original "$malicious_value")"
done

echo "Benchmarking new optimized implementation (no subshell)..."
time for i in $(seq 1 $ITERATIONS); do
  terminal_safe_text_new "$malicious_value" val
done
