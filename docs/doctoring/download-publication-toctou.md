# Download publication TOCTOU hardening

## Problem boundary

`download-reference.sh` accepts a caller-selected final output pathname. A preflight `-L` check can reject a symlink that already exists, but it cannot prove that the same pathname will still refer to the same object when `yt-dlp` later opens it. An attacker with write access to the output directory can replace the pathname after the check and before the write. MITRE classifies this state-change gap as CWE-367 and explicitly notes that checking before use can create a false sense of security when resource identity is not assured. MITRE also classifies following a filename that resolves through an unintended link as CWE-59.

The original Sentinel patch correctly rejected a symlink present at entry, but it still passed the final pathname directly to `yt-dlp`. That left the check/use interval open and therefore did not fully close the arbitrary-file-overwrite boundary.

## Security design

The safe contract separates **download** from **publication**:

1. Reject a symlink that is already present and tell the caller to remove it and retry.
2. Preserve a non-empty regular output as an explicit cache hit.
3. Preserve the existing zero-byte cache-miss contract by removing only that caller-selected regular-file entry before network work; reject directories, devices, FIFOs, sockets, and other non-regular entries.
4. Create a private unpredictable staging directory inside the output directory with `mktemp -d`.
5. Give `yt-dlp` only the staged pathname, never the final caller-controlled pathname.
6. Verify that the staged result is a regular non-symlink file.
7. Publish with a same-filesystem hard link to the final pathname. Hard-link creation is no-clobber: if any object appears at the destination during the download, publication fails instead of following or overwriting it.
8. On publication conflict, retain fail-closed behavior and tell the caller the next action: remove the unexpected path and retry.
9. Clean the private staging directory on both success and failure.

This design avoids relying on a second path check to establish identity. The final publication operation itself is the conflict detector.

## Executable regression

`test_download_reference_symlink_race.sh` uses a controlled `yt-dlp` double that waits until the script has passed its initial validation, then replaces the final output pathname with a symlink to a protected victim before writing the requested download path.

The previous direct-to-final implementation writes through that symlink and changes the victim. The repaired implementation downloads to the private staged path; final publication then observes that the destination appeared, fails closed, and leaves the victim byte-for-byte unchanged. The repository `CLI UX` workflow runs this regression and ShellCheck alongside the existing CLI contract suite.

### RED → GREEN traceability

- Initial insufficient fix: `0d5d001edbb9cb9779d6691209aeb8987c2111f2`
- Race regression introduced: `d86246bd98edecdd83c5f4cc5d1855e0b195be75`
- Regression wired into required repository CI: `5d866dd0669aea115027ba516e798f8cf2b45e3b`
- Fail-closed race expectation pinned: `63c6653128a89d116f34910ab6f8ecc38da9ab8b`
- Staged/no-clobber publication repair: `ef874002a60f8c6d912ec8f43f4b42faf833cc2a`
- Actionable pre-existing-symlink copy restored: `bbf3b4514dbed7c278c42fe3e141ea599ed924d9`

## Rollback rule

Do not roll back to direct `yt-dlp -o "$OUTPUT"` publication, even if an entry-time symlink check remains. A safe rollback may disable the development convenience or fail before download, but it must keep downloaded bytes away from the final pathname until a no-clobber publication step.

## References

The MITRE Corporation. (2026). *CWE-59: Improper link resolution before file access ('Link Following') (Version 4.20).* Common Weakness Enumeration. Retrieved August 28, 2026, from https://cwe.mitre.org/data/definitions/59.html

The MITRE Corporation. (2026). *CWE-367: Time-of-check time-of-use (TOCTOU) race condition (Version 4.20).* Common Weakness Enumeration. Retrieved August 28, 2026, from https://cwe.mitre.org/data/definitions/367.html
