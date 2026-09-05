# Reference-video file-size display units

## Decision

The download CLI preserves the exact byte count and adds a one-decimal human-readable binary multiple for values at or above 1024 bytes. The display uses `KiB` for 2^10 bytes and `MiB` for 2^20 bytes.

The predecessor branch divided by 1024 and 1,048,576 but labelled the results `KB` and `MB`. That mixes binary arithmetic with SI symbols: NIST defines 1 KiB as 1024 bytes and 1 MiB as 1,048,576 bytes, while `kB`/`MB` are decimal multiples. The IEC style guide likewise distinguishes kB/MB from KiB/MiB. The repair changes the labels rather than silently changing the divisor, preserving the original binary-size intent.

A single decimal digit is derived with Bash integer arithmetic. The exact byte count remains in parentheses, so rounding cannot erase the source measurement. Invalid non-integer input is rejected by the formatter rather than rendered as an invented size.

## Alternatives and limits

Using decimal kB/MB would also be valid if the divisor changed to powers of 1000. It was rejected here because the generated change explicitly chose powers of 1024 and existing engineering users may expect binary multiples for local files. Printing bytes only is exact but does not satisfy the buyer-visible readability goal.

This formatting is presentation only. It does not alter downloaded bytes, cache identity, integrity, storage accounting, bandwidth measurement, or quota semantics. The terminal neutralization boundary remains responsible for rendering untrusted path/URL text; the formatter accepts only the locally measured integer byte count.

## Verification contract

Executable shell tests pin bytes below 1024, exact KiB/MiB boundaries, fractional binary multiples, and invalid input. The repository CLI workflow ShellChecks both the production helper and the focused test, then executes the existing CLI contracts and the file-size contract on the exact pull-request head.

## Traceability

National Institute of Standards and Technology. (n.d.). *Definitions of the SI units: The binary prefixes*. Retrieved September 5, 2026, from https://physics.nist.gov/cuu/Units/binary.html

International Electrotechnical Commission. (n.d.). *IEC style guide: List of commonly used units and their symbols*. Retrieved September 5, 2026, from https://styleguide.iec.ch/
