# Product / Technical Gap Baseline

Status: code-current baseline for `seedream_evasepic` on `develop` and active commercial-development work.

## Product boundary

`seedream_evasepic` is the product owner for reference-media preparation used by the Seedream/EvaEpic plugin: reference video acquisition, deterministic media probing, frame/audio extraction, transcription-facing artifacts, and the CLI feedback required to operate those steps safely. It does not own organization-wide LLM routing, agent runtime, identity, egress policy, sandboxing, or SOC controls; those responsibilities remain with their released CWL foundation owners when this plugin needs them.

The current reference-video bounded context uses these domain concepts:

- `ReferenceAsset`: a caller-selected media file or acquired reference file.
- `ProbeMetadata`: duration, dimensions, frame-rate representation, and stream presence returned by the ffprobe adapter.
- `ExtractionPlan`: requested frame count plus the derived frame sampling interval.
- `GeneratedArtifact`: extracted frame, audio file, transcript-facing input, or metadata record.

FFmpeg, ffprobe, yt-dlp, and Whisper-facing commands are external/legacy adapters. Dynamic values remain data arguments; command/program text is fixed where practical. Terminal rendering is a separate output boundary and must not reinterpret external data as terminal control syntax.

## Current invariants

1. Shell command construction keeps dynamic URL/path/model/timing values out of executable shell or awk program text.
2. Option-taking CLI utilities use an end-of-options boundary where supported before caller-controlled path/URL arguments.
3. Terminal output separates trusted styling from external values. External values are rendered through `terminal_safe_text` / `terminal_print_value` before an interactive terminal can interpret C0/C1, line-structure, bidi, or other format controls.
4. `NUM_FRAMES` remains a positive integer and probed duration must produce a positive sampling interval before extraction begins.
5. Cache hits preserve an existing non-empty reference artifact instead of silently downloading over it.
6. Product evidence distinguishes a behavior/security contract from a performance claim: shell tests do not establish latency or throughput improvements.

## Active gap: ffprobe-derived terminal values

Protected `develop@ce1cccfc67af6682e277b460864eacfdc121b622` printed `DURATION`, `RESOLUTION`, and `FPS` inside a `%b` terminal sink. Those requested ffprobe fields are structural probe values, so a claim that a specially crafted media tag directly creates arbitrary shell-command execution is not established. The valid boundary is narrower: output returned by an external probe process must not be able to inject live terminal controls if that boundary is malformed, replaced, or compromised.

Active PR #396 repairs this boundary by neutralizing the three displayed probe values before mixing them with trusted ANSI styling. The executable acceptance fixture uses a fake ffprobe process that emits an actual ESC/CSI sequence in a structural field and requires the terminal stream to contain visible escaped text rather than the live attacker sequence.

## Evidence gap repaired with PR #396

The repository already had `test_terminal_output.sh`, but the local `CLI UX` workflow only passed that file to ShellCheck and did not execute its security contracts. PR #396 updates the workflow so the exact pull-request head executes:

- `test_cli_ux.sh`;
- `test_terminal_output.sh`;
- `test_ffprobe_terminal_output.sh`.

The workflow retains exact-head checkout/verification, read-only contents permission, `cancel-in-progress: true`, ShellCheck, and a clean-worktree assertion.

## Remaining buyer-visible gaps

### Real-media acceptance

Synthetic hostile bytes are appropriate for unit/regression testing, but release confidence also needs a small right-cleared set of real reference media covering silent video, audio+video, variable/common frame rates, unusual but valid dimensions, non-ASCII file names, and ffprobe failure. Acceptance must preserve the same generated artifact contract without relying on attacker-shaped synthetic media as product realism evidence.

### Operability and recovery

The CLI should expose which external dependency failed, preserve non-sensitive diagnostic context, and leave partial workspaces/artifacts in a documented state. Recovery tests should distinguish missing executable, probe failure, invalid duration, frame extraction failure, missing audio, and transcription failure. Caller-controlled paths or external output must not be echoed without terminal neutralization.

### Performance evidence

Process-count reductions or Bash implementation changes are not promoted as buyer-visible performance improvements without a reproducible benchmark. A valid benchmark records shell/runtime versions, OS/CPU, input size and control-character density where relevant, warm-up/repetition policy, and the exact head under test. Behavioral/security parity is required before optimization evidence is considered.

### Release evidence

Release-ready means the unchanged protected-head descendant has terminal applicable repository tests, CLI contracts, security/static-analysis/dependency gates, no valid unresolved review finding, code-current changelog/recovery documentation, and an immutable release artifact with provenance/rollback evidence where the repository's release mechanism applies. Predecessor GREEN, self-approval, force rewriting, gate weakening, no-op retriggers, or generated severity labels are not release evidence.

## Decision record for the active repair

Problem: external probe output was displayed through a `%b` terminal sink, while the existing security regression suite was not fully executed by CI.

Constraints: preserve trusted ANSI styling, preserve existing extraction behavior, avoid claiming media-driven RCE without an executable path, keep the repair local to this product, and do not invent a repository-wide Sentinel doctrine.

Alternatives considered:

- Trust ffprobe structural fields and leave the sink unchanged — rejected because the external-process boundary can fail or be substituted independently of normal media semantics.
- Strip all non-ASCII output — rejected because it destroys legitimate user-visible data and is unnecessary for terminal-control safety.
- Neutralize external values, retain trusted styling, and execute the regression contracts on the exact head — selected because it preserves information while separating data from terminal control syntax.

Risk: neutralization can regress if a new external value bypasses the centralized renderer or if a regression file stops executing in CI. The workflow and hostile-output fixture make both failures observable.

Follow-up: complete exact-head checks for PR #396, then continue with right-cleared real-media acceptance and recovery evidence rather than broadening the security claim.
