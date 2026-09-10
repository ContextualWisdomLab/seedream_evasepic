# Product / Technical Gap Baseline

Last reviewed: 2026-09-10

This document records buyer-visible gaps that are demonstrated by executable evidence. It is not a vulnerability-severity ledger and does not turn hypotheses into accepted findings.

## Reference-video download publication

### Product boundary

`download-reference.sh` accepts a caller-owned URL and output path, may perform network work through `yt-dlp`, and publishes the resulting artifact at that output path. A non-empty regular file remains a cache hit. A pre-existing final-component symlink is rejected.

### Valid finding

A symlink check performed before the download is not a complete publication control. The final output directory entry can change after that check and before `yt-dlp` opens the path. The executable regression in `test_download_reference_publish.sh` replaces the final path with a symlink while the `yt-dlp` test double is running. Against the pre-staging implementation, the write reaches the symlink target.

### Current repair

Implementation evidence: `3694ef7b3f8ed7a6c7a8c56c7986b824f472d0b0`.

The download now writes to a private `0700` staging directory created beside the requested output. After `yt-dlp` completes, a regular staged artifact is renamed onto the final path on the same filesystem. A late final-component symlink is therefore replaced as a directory entry instead of becoming `yt-dlp`'s write target. Existing cache-hit and zero-byte cache-miss semantics are preserved.

The previous `.jules/sentinel.md` rule claiming that an immediate `[ -L "$OUTPUT" ]` precheck prevents TOCTOU attacks was removed rather than generalized.

### Remaining gap and acceptance

This repair does **not** claim to make an attacker-writable parent directory safe. Parent-directory replacement or namespace manipulation is a separate trust boundary. If the product must accept output parents writable by an untrusted principal, the next repair needs an fd-relative/native publication primitive or an equivalent directory-identity control, with a regression that swaps the parent directory itself.

Before this lane can be accepted or released:

- `test_cli_ux.sh`, `test_download_reference_publish.sh`, ShellCheck, Security Scan, SAST and CodeQL must be terminal on the same exact PR head;
- the raced final-component symlink target must remain byte-for-byte unchanged while the requested output becomes a regular downloaded artifact;
- cache hit, zero-byte cache miss, yt-dlp failure cleanup, and no-partial-publication behavior must remain executable contracts;
- severity must be based on the actual privilege/trust boundary rather than inferred from the presence of a symlink alone;
- no merge or release claim is valid while required exact-head gates are pending or failing.
