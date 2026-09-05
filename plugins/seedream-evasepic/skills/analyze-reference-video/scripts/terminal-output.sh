#!/bin/bash
# Shared terminal-output neutralization for untrusted CLI values.
#
# Bash variables cannot contain NUL bytes. Every other C0 control character,
# DEL, Unicode C1 control, line separator, paragraph separator, and common
# bidirectional/invisible format control is rendered as visible text before the
# value is mixed with trusted ANSI styling.

# Return a terminal-safe representation of one untrusted value.
terminal_safe_text() {
  local value="${1-}"
  # Neutralize the C0 set (except NUL, which cannot exist in a Bash variable).
  value=${value//$'\x01'/\\x01}
  value=${value//$'\x02'/\\x02}
  value=${value//$'\x03'/\\x03}
  value=${value//$'\x04'/\\x04}
  value=${value//$'\x05'/\\x05}
  value=${value//$'\x06'/\\x06}
  value=${value//$'\x07'/\\x07}
  value=${value//$'\x08'/\\x08}
  value=${value//$'\x09'/\\x09}
  value=${value//$'\x0a'/\\x0A}
  value=${value//$'\x0b'/\\x0B}
  value=${value//$'\x0c'/\\x0C}
  value=${value//$'\x0d'/\\x0D}
  value=${value//$'\x0e'/\\x0E}
  value=${value//$'\x0f'/\\x0F}
  value=${value//$'\x10'/\\x10}
  value=${value//$'\x11'/\\x11}
  value=${value//$'\x12'/\\x12}
  value=${value//$'\x13'/\\x13}
  value=${value//$'\x14'/\\x14}
  value=${value//$'\x15'/\\x15}
  value=${value//$'\x16'/\\x16}
  value=${value//$'\x17'/\\x17}
  value=${value//$'\x18'/\\x18}
  value=${value//$'\x19'/\\x19}
  value=${value//$'\x1a'/\\x1A}
  value=${value//$'\x1b'/\\x1B}
  value=${value//$'\x1c'/\\x1C}
  value=${value//$'\x1d'/\\x1D}
  value=${value//$'\x1e'/\\x1E}
  value=${value//$'\x1f'/\\x1F}
  value=${value//$'\x7f'/\\x7F}

  # Neutralize Unicode U+0080..U+009F when supplied as valid UTF-8. These are
  # the C1 control characters defined alongside ECMA-48 control functions.
  value=${value//$'\xC2\x80'/\\u0080}
  value=${value//$'\xC2\x81'/\\u0081}
  value=${value//$'\xC2\x82'/\\u0082}
  value=${value//$'\xC2\x83'/\\u0083}
  value=${value//$'\xC2\x84'/\\u0084}
  value=${value//$'\xC2\x85'/\\u0085}
  value=${value//$'\xC2\x86'/\\u0086}
  value=${value//$'\xC2\x87'/\\u0087}
  value=${value//$'\xC2\x88'/\\u0088}
  value=${value//$'\xC2\x89'/\\u0089}
  value=${value//$'\xC2\x8a'/\\u008A}
  value=${value//$'\xC2\x8b'/\\u008B}
  value=${value//$'\xC2\x8c'/\\u008C}
  value=${value//$'\xC2\x8d'/\\u008D}
  value=${value//$'\xC2\x8e'/\\u008E}
  value=${value//$'\xC2\x8f'/\\u008F}
  value=${value//$'\xC2\x90'/\\u0090}
  value=${value//$'\xC2\x91'/\\u0091}
  value=${value//$'\xC2\x92'/\\u0092}
  value=${value//$'\xC2\x93'/\\u0093}
  value=${value//$'\xC2\x94'/\\u0094}
  value=${value//$'\xC2\x95'/\\u0095}
  value=${value//$'\xC2\x96'/\\u0096}
  value=${value//$'\xC2\x97'/\\u0097}
  value=${value//$'\xC2\x98'/\\u0098}
  value=${value//$'\xC2\x99'/\\u0099}
  value=${value//$'\xC2\x9a'/\\u009A}
  value=${value//$'\xC2\x9b'/\\u009B}
  value=${value//$'\xC2\x9c'/\\u009C}
  value=${value//$'\xC2\x9d'/\\u009D}
  value=${value//$'\xC2\x9e'/\\u009E}
  value=${value//$'\xC2\x9f'/\\u009F}

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
