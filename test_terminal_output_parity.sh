#!/bin/bash
set -euo pipefail

SCRIPT_DIRECTORY="plugins/seedream-evasepic/skills/analyze-reference-video/scripts"
. "$SCRIPT_DIRECTORY/terminal-output.sh"

terminal_safe_text_old() {
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

fail() {
  echo "FAIL: $1" >&2
  false
}

echo "Testing parity between old and new implementations..."

for code in {1..31} 127; do
  if [ "$code" -eq 127 ]; then
    control=$'\177'
  else
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\${octal}"
  fi

  old_out="$(terminal_safe_text_old "a${control}b")"
  terminal_safe_text "a${control}b" new_out
  if [ "$old_out" != "$new_out" ]; then
    fail "Mismatch on ASCII control code $code: old='$old_out', new='$new_out'"
  fi
done

for code in {128..159}; do
  printf -v octal '%03o' "$code"
  printf -v control '%b' "\\302\\${octal}"
  old_out="$(terminal_safe_text_old "a${control}b")"
  terminal_safe_text "a${control}b" new_out
  if [ "$old_out" != "$new_out" ]; then
    fail "Mismatch on Unicode C1 code $code: old='$old_out', new='$new_out'"
  fi
done

controls=(
  $'\342\200\213' $'\342\200\214' $'\342\200\215' $'\342\200\216'
  $'\342\200\217' $'\342\200\250' $'\342\200\251' $'\342\200\252'
  $'\342\200\253' $'\342\200\254' $'\342\200\255' $'\342\200\256'
  $'\342\201\240' $'\342\201\246' $'\342\201\247' $'\342\201\250'
  $'\342\201\251' $'\330\234' $'\357\273\277'
)

for control in "${controls[@]}"; do
  old_out="$(terminal_safe_text_old "a${control}b")"
  terminal_safe_text "a${control}b" new_out
  if [ "$old_out" != "$new_out" ]; then
    fail "Mismatch on special formatting control: old='$old_out', new='$new_out'"
  fi
done

old_out_stdout="$(terminal_safe_text_old "a${controls[0]}b")"
new_out_stdout="$(terminal_safe_text "a${controls[0]}b")"
if [ "$new_out_stdout" != "$old_out_stdout" ]; then
  fail "Mismatch when printing directly to stdout"
fi

echo "PASS: Functional parity verified."
