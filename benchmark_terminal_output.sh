#!/bin/bash
set -euo pipefail

SCRIPT_DIRECTORY="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
. "$SCRIPT_DIRECTORY/terminal-output.sh"

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

malicious_value=$'safe\033[31mPWNED\033[0m\nFORGED\rLINE\tBELL\007'
malicious_value+=$'\302\233CSI\342\200\256RTL\342\200\250NEXT'

echo "Original:"
time for i in {1..100}; do
  safe_value="$(terminal_safe_text_original "$malicious_value")"
done

echo "Optimized:"
time for i in {1..100}; do
  terminal_safe_text safe_value "$malicious_value"
done
