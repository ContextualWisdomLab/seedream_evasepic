# Product Technical Gap Baseline

Updated: 2026-09-12

## Reference-video download target integrity

- Status: repair implemented; exact-head hosted revalidation pending.
- Scope: `plugins/seedream-evasepic/skills/analyze-reference-video/scripts/download-reference.sh`.
- RED evidence: PR [#417](https://github.com/ContextualWisdomLab/seedream_evasepic/pull/417) and test-first commit [`4b5c96d4300fa76a4dd717066e6dc11c15530c08`](https://github.com/ContextualWisdomLab/seedream_evasepic/commit/4b5c96d4300fa76a4dd717066e6dc11c15530c08). The exact-tree fixture returned exit 1 locally because the victim changed. Hosted CLI UX run [`34687635455`](https://github.com/ContextualWisdomLab/seedream_evasepic/actions/runs/34687635455) was runner-queued before the successor head, so it is not used as terminal RED or GREEN authority.
- Root cause: `[ -L "$OUTPUT" ]` checked only one instant. An attacker could replace the target with a symlink before `yt-dlp -o "$OUTPUT"` opened it, redirecting the write to the symlink referent.
- Repair: download into a private `mktemp -d` directory beside the output, clean it through an EXIT trap, and publish the completed file with a same-filesystem rename. The existing preflight and cache semantics remain intact.
- Contract: a deterministic fake downloader swaps the final target after preflight. The victim must remain byte-for-byte unchanged, the final target must not be a symlink, and the downloaded payload must be published.
- Remaining gate: terminal exact-head CLI UX, Security, SAST, CodeQL, and independent review evidence. Draft remains mandatory until those gates settle.
