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
  value=${value//$'\001'/\\x01}
  value=${value//$'\002'/\\x02}
  value=${value//$'\003'/\\x03}
  value=${value//$'\004'/\\x04}
  value=${value//$'\005'/\\x05}
  value=${value//$'\006'/\\x06}
  value=${value//$'\007'/\\x07}
  value=${value//$'\010'/\\x08}
  value=${value//$'\011'/\\x09}
  value=${value//$'\012'/\\x0A}
  value=${value//$'\013'/\\x0B}
  value=${value//$'\014'/\\x0C}
  value=${value//$'\015'/\\x0D}
  value=${value//$'\016'/\\x0E}
  value=${value//$'\017'/\\x0F}
  value=${value//$'\020'/\\x10}
  value=${value//$'\021'/\\x11}
  value=${value//$'\022'/\\x12}
  value=${value//$'\023'/\\x13}
  value=${value//$'\024'/\\x14}
  value=${value//$'\025'/\\x15}
  value=${value//$'\026'/\\x16}
  value=${value//$'\027'/\\x17}
  value=${value//$'\030'/\\x18}
  value=${value//$'\031'/\\x19}
  value=${value//$'\032'/\\x1A}
  value=${value//$'\033'/\\x1B}
  value=${value//$'\034'/\\x1C}
  value=${value//$'\035'/\\x1D}
  value=${value//$'\036'/\\x1E}
  value=${value//$'\037'/\\x1F}
  value=${value//$'\177'/\\x7F}

  # Neutralize Unicode U+0080..U+009F when supplied as valid UTF-8. These are
  # the C1 control characters defined alongside ECMA-48 control functions.
  value=${value//$'\302\200'/\\u0080}
  value=${value//$'\302\201'/\\u0081}
  value=${value//$'\302\202'/\\u0082}
  value=${value//$'\302\203'/\\u0083}
  value=${value//$'\302\204'/\\u0084}
  value=${value//$'\302\205'/\\u0085}
  value=${value//$'\302\206'/\\u0086}
  value=${value//$'\302\207'/\\u0087}
  value=${value//$'\302\210'/\\u0088}
  value=${value//$'\302\211'/\\u0089}
  value=${value//$'\302\212'/\\u008A}
  value=${value//$'\302\213'/\\u008B}
  value=${value//$'\302\214'/\\u008C}
  value=${value//$'\302\215'/\\u008D}
  value=${value//$'\302\216'/\\u008E}
  value=${value//$'\302\217'/\\u008F}
  value=${value//$'\302\220'/\\u0090}
  value=${value//$'\302\221'/\\u0091}
  value=${value//$'\302\222'/\\u0092}
  value=${value//$'\302\223'/\\u0093}
  value=${value//$'\302\224'/\\u0094}
  value=${value//$'\302\225'/\\u0095}
  value=${value//$'\302\226'/\\u0096}
  value=${value//$'\302\227'/\\u0097}
  value=${value//$'\302\230'/\\u0098}
  value=${value//$'\302\231'/\\u0099}
  value=${value//$'\302\232'/\\u009A}
  value=${value//$'\302\233'/\\u009B}
  value=${value//$'\302\234'/\\u009C}
  value=${value//$'\302\235'/\\u009D}
  value=${value//$'\302\236'/\\u009E}
  value=${value//$'\302\237'/\\u009F}

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
