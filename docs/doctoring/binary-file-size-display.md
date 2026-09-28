# Binary file-size display contract

## Status

Active pull-request behavior only until this branch reaches protected `develop`.

## Decision

`download-reference.sh` scales downloaded byte counts by repeated division by 1024. Therefore the human-readable labels use the binary-prefix symbols `KiB`, `MiB`, `GiB`, and `TiB`, while values below 1024 remain in `B`.

Using `KB`, `MB`, `GB`, or `TB` for this implementation would mix decimal SI-prefix symbols with binary powers and can make the displayed quantity ambiguous. NIST's binary-prefix guidance defines `1 KiB = 2^10 B`, `1 MiB = 2^20 B`, and the corresponding `GiB`/`TiB` forms. The product output follows that convention rather than changing the existing 1024-based arithmetic.

## Buyer-visible acceptance

- A downloaded file containing exactly 1,048,576 bytes is displayed as `1.00 MiB`.
- The same 1024-based path must not display that value as `1.00 MB`.
- Exact byte counts below 1024 retain the `B` suffix.
- The unit correction does not change download authority, cache behavior, path handling, network access, or artifact bytes.

`test_file_size_units.sh` exercises the real download script with a local fake `yt-dlp` that writes an exact 1 MiB artifact, then validates the rendered output. The CLI UX workflow ShellChecks and executes that contract on the exact pull-request head.

## Rollback

Reverting this slice should revert the binary-unit regression, its workflow registration, this doctoring note, and the output-label change together. Do not revert to decimal symbols while retaining 1024-based scaling.

## References

National Institute of Standards and Technology. (n.d.). *Definitions of the SI units: The binary prefixes*. https://www.physics.nist.gov/cuu/Units/binary.html

National Institute of Standards and Technology. (2019). *The International System of Units (SI)* (NIST Special Publication 330, 2019 ed.). U.S. Department of Commerce. https://doi.org/10.6028/NIST.SP.330-2019
