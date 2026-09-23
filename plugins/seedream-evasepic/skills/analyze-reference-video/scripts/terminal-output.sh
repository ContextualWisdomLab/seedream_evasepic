#!/bin/bash
# Shared terminal-output neutralization for untrusted CLI values.
#
# Bash variables cannot contain NUL bytes. Every other C0 control character,
# DEL, Unicode C1 control, line separator, paragraph separator, and common
# bidirectional/invisible format control is rendered as visible text before the
# value is mixed with trusted ANSI styling.

# Precompute C0 and C1 control arrays at script load time to avoid invoking
# 'printf -v' 63 times per function call, significantly reducing overhead.
declare -g -a _TERMINAL_SAFE_C0_CONTROLS _TERMINAL_SAFE_C0_REPLACEMENTS
declare -g -a _TERMINAL_SAFE_C1_CONTROLS _TERMINAL_SAFE_C1_REPLACEMENTS

for _terminal_safe_code in {1..31}; do
  printf -v _terminal_safe_octal '%03o' "$_terminal_safe_code"
  printf -v _terminal_safe_control '%b' "\\${_terminal_safe_octal}"
  printf -v _terminal_safe_replacement '\\x%02X' "$_terminal_safe_code"
  _TERMINAL_SAFE_C0_CONTROLS[$_terminal_safe_code]="$_terminal_safe_control"
  _TERMINAL_SAFE_C0_REPLACEMENTS[$_terminal_safe_code]="$_terminal_safe_replacement"
done
for _terminal_safe_code in {128..159}; do
  printf -v _terminal_safe_octal '%03o' "$_terminal_safe_code"
  printf -v _terminal_safe_control '%b' "\\302\\${_terminal_safe_octal}"
  printf -v _terminal_safe_replacement '\\u%04X' "$_terminal_safe_code"
  _TERMINAL_SAFE_C1_CONTROLS[$_terminal_safe_code]="$_terminal_safe_control"
  _TERMINAL_SAFE_C1_REPLACEMENTS[$_terminal_safe_code]="$_terminal_safe_replacement"
done
unset _terminal_safe_code _terminal_safe_octal _terminal_safe_control _terminal_safe_replacement

# Return a terminal-safe representation of one untrusted value.
terminal_safe_text() {
  local value="${1-}"
  local code

  # Neutralize the C0 set (except NUL, which cannot exist in a Bash variable).
  for code in {1..31}; do
    value=${value//"${_TERMINAL_SAFE_C0_CONTROLS[$code]}"/"${_TERMINAL_SAFE_C0_REPLACEMENTS[$code]}"}
  done
  value=${value//$'\177'/\\x7F}

  # Neutralize Unicode U+0080..U+009F when supplied as valid UTF-8. These are
  # the C1 control characters defined alongside ECMA-48 control functions.
  for code in {128..159}; do
    value=${value//"${_TERMINAL_SAFE_C1_CONTROLS[$code]}"/"${_TERMINAL_SAFE_C1_REPLACEMENTS[$code]}"}
  done

  # Keep Unicode line, paragraph, bidirectional, and invisible format controls
  # from changing terminal line structure or the visual ordering of a path/URL.
  value=${value//$'\342\200\213'/\\u200B} # ZERO WIDTH SPACE
  value=${value//$'\342\200\214'/\\u200C} # ZERO WIDTH NON-JOINER
  value=${value//$'\342\200\215'/\\u200D} # ZERO WIDTH JOINER
  value=${value//$'\342\200\216'/\\u200E} # LEFT-TO-RIGHT MARK
  value=${value//$'\342\200\217'/\\u200F} # RIGHT-TO-LEFT MARK
  value=${value//$'\342\200\250'/\\u2028} # LINE SEPARATOR
  value=${value//$'\342\200\251'/\\u2029} # PARAGRAPH SEPARATOR
  value=${value//$'\342\200\252'/\\u202A} # LEFT-TO-RIGHT EMBEDDING
  value=${value//$'\342\200\253'/\\u202B} # RIGHT-TO-LEFT EMBEDDING
  value=${value//$'\342\200\254'/\\u202C} # POP DIRECTIONAL FORMATTING
  value=${value//$'\342\200\255'/\\u202D} # LEFT-TO-RIGHT OVERRIDE
  value=${value//$'\342\200\256'/\\u202E} # RIGHT-TO-LEFT OVERRIDE
  value=${value//$'\342\201\240'/\\u2060} # WORD JOINER
  value=${value//$'\342\201\246'/\\u2066} # LEFT-TO-RIGHT ISOLATE
  value=${value//$'\342\201\247'/\\u2067} # RIGHT-TO-LEFT ISOLATE
  value=${value//$'\342\201\250'/\\u2068} # FIRST STRONG ISOLATE
  value=${value//$'\342\201\251'/\\u2069} # POP DIRECTIONAL ISOLATE
  value=${value//$'\330\234'/\\u061C}     # ARABIC LETTER MARK
  value=${value//$'\357\273\277'/\\uFEFF} # ZERO WIDTH NO-BREAK SPACE/BOM

  printf '%s' "$value"
}

# Print trusted ANSI prefix/suffix around a neutralized untrusted value.
terminal_print_value() {
  local prefix="${1-}"
  local value="${2-}"
  local suffix="${3-}"
  local safe_value

  safe_value="$(terminal_safe_text "$value")"
  printf '%b%s%b\n' "$prefix" "$safe_value" "$suffix"
}
