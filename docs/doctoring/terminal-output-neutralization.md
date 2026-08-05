# Terminal output neutralization

## Decision

The reference-video CLI keeps trusted color sequences separate from untrusted
URLs, paths, model arguments, and external-result values. Every untrusted value
that is displayed by Bash passes through one shared renderer:

- `terminal_safe_text` converts C0 controls, DEL, Unicode C1 controls, line and
  paragraph separators, common bidirectional controls, and invisible format
  controls into visible escape notation;
- `terminal_print_value` applies trusted ANSI prefix/suffix bytes only after the
  untrusted value has been neutralized; and
- the Python Whisper fallback omits user-controlled paths from terminal output
  and allowlists the short language identifier before displaying it.

The scripts still pass original values to file and process APIs. Neutralization
is an output-boundary operation and must not silently rename the file or rewrite
the URL being processed.

## Why `%s` alone is insufficient

A fixed `printf` format and `%s` prevent textual backslash sequences such as
`\033` from being interpreted by `printf`. They do not remove an actual ESC byte
already present in the argument. They also do not prevent CR/LF record forgery,
BEL, backspace, C1 controls, Unicode line separators, or bidirectional overrides
from changing how a terminal renders the value.

ECMA-48 defines control functions embedded in character-coded data for devices
that image characters. MITRE classifies failure to neutralize escape, meta, or
control sequences sent to a downstream component as CWE-150 and explicitly
identifies ANSI injection as an alternate term. OWASP's logging guidance likewise
requires sanitizing external event data against CR, LF, and delimiter injection
and encoding for the downstream format.

The product therefore treats the terminal itself as a rendering interpreter, not
as a passive byte sink.

## Threat model

An attacker can supply a URL, local path, output path, or invalid model argument
through the CLI. Files and media metadata can also contain attacker-controlled
text. Without neutralization, a value could:

- clear or rewrite visible output;
- move the cursor and forge a success or authentication prompt;
- split one status record into several lines;
- ring the terminal bell or apply destructive backspace behavior;
- visually reorder a filename with bidirectional controls; or
- trigger implementation-specific terminal behavior beyond color changes.

Trusted ANSI colors remain deliberately supported. The security invariant is
that only repository-owned constants may generate terminal control bytes.

## Implementation boundary

The Bash renderer is dependency-free and preserves ordinary UTF-8 text. Bash
variables cannot contain NUL; all other C0 bytes are rendered as `\xNN`, Unicode
C1 controls as `\uNNNN`, and the enumerated line/bidirectional/invisible controls
as visible Unicode escape notation. Values remain bounded by the operating
system's argument and environment limits; this module does not replace CLI input
size limits where those are required.

The helper must be sourced from its own resolved script directory so a caller's
working directory cannot substitute a different implementation. Dynamic values
must never be added to trusted `%b` prefix/suffix arguments.

## Verification contract

The regression suite uses actual bytes and code points, not only literal text:

- ESC/CSI color injection;
- LF and CR record injection;
- TAB, BEL, DEL, and remaining C0 controls;
- Unicode C1 CSI;
- Unicode LINE SEPARATOR;
- RIGHT-TO-LEFT OVERRIDE; and
- all URL/path/model display branches in the three CLI scripts.

Tests require the attacker marker to remain readable as escaped text while the
original terminal-control sequence is absent. Static assertions also reject
user-controlled variables passed through `%b` and reject Python fallback prints
that contain caller-owned paths.

The exact pull-request head must additionally pass ShellCheck, CLI UX tests,
Security Scan, Semgrep, and independent current-head review before merge.

## Limitations

- Child tools can have their own output behavior. The wrappers minimize their
  verbosity, but each external tool upgrade still requires review of whether it
  echoes caller-owned paths or remote metadata.
- Terminal implementations support non-standard sequences beyond ECMA-48. A
  centralized printable representation reduces that attack surface but is not a
  claim that every terminal emulator is defect-free.
- This work does not claim formal ECMA, ISO, MITRE, or OWASP conformity.

## References

Ecma International. (1991). *Control functions for coded character sets*
(ECMA-48, 5th ed.; ISO/IEC 6429). https://ecma-international.org/publications-and-standards/standards/ecma-48/

MITRE Corporation. (2026). *CWE-150: Improper neutralization of escape, meta, or
control sequences* (CWE Version 4.20). https://cwe.mitre.org/data/definitions/150.html

MITRE Corporation. (2026). *CWE-117: Improper output neutralization for logs*
(CWE Version 4.20). https://cwe.mitre.org/data/definitions/117.html

OWASP Foundation. (n.d.). *Logging cheat sheet*. OWASP Cheat Sheet Series.
Retrieved August 5, 2026, from
https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
