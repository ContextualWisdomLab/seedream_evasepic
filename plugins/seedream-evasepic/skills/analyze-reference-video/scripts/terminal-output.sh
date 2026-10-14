#!/bin/bash
# Shared terminal-output neutralization for untrusted CLI values.
#
# Bash variables cannot contain NUL bytes. Every other C0 control character,
# DEL, Unicode C1 control, line separator, paragraph separator, and common
# bidirectional/invisible format control is rendered as visible text before the
# value is mixed with trusted ANSI styling.

# Precalculate static string formats for control characters at load time to avoid
# slow printf -v operations inside the frequently called terminal_safe_text function.
declare -a _C0_CONTROL
declare -a _C0_REPLACEMENT
declare -a _C1_CONTROL
declare -a _C1_REPLACEMENT

_init_terminal_controls() {
  local code octal control replacement tmp
  for code in {1..31}; do
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\${octal}"
    _C0_CONTROL[code]="$control"
    printf -v tmp '\\x%02X' "$code"
    _C0_REPLACEMENT[code]="$tmp"
  done
  for code in {128..159}; do
    printf -v octal '%03o' "$code"
    printf -v control '%b' "\\302\\${octal}"
    _C1_CONTROL[code]="$control"
    printf -v tmp '\\u%04X' "$code"
    _C1_REPLACEMENT[code]="$tmp"
  done
}
_init_terminal_controls
unset -f _init_terminal_controls

# Return a terminal-safe representation of one untrusted value.
terminal_safe_text() {
  local value="${1-}"
  local code

  # Neutralize the C0 set (except NUL, which cannot exist in a Bash variable).
  for code in {1..31}; do
    value=${value//"${_C0_CONTROL[code]}"/"${_C0_REPLACEMENT[code]}"}
  done
  value=${value//$'\177'/\\x7F}

  # Neutralize Unicode U+0080..U+009F when supplied as valid UTF-8. These are
  # the C1 control characters defined alongside ECMA-48 control functions.
  for code in {128..159}; do
    value=${value//"${_C1_CONTROL[code]}"/"${_C1_REPLACEMENT[code]}"}
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
