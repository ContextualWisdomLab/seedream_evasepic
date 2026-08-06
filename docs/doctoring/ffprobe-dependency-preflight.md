# FFprobe dependency preflight

## Decision

The reference-video frame extractor treats `ffmpeg` and `ffprobe` as two
separate executable dependencies. The script resolves both command paths before
it allocates the output directory or probes media metadata. If either resolved
path is not executable, the script exits with status `1` and prints a fixed,
actionable diagnostic to standard error.

`ffprobe` is not an optional enhancement. It is the metadata reader that supplies
video duration, dimensions, frame rate, and stream types to the later frame and
audio extraction steps. Continuing when that executable is absent converts a
configuration error into misleading downstream evidence such as a zero-duration
media failure.

## User-visible contract

When `FFPROBE` names a missing or non-executable path, the command emits:

```text
Error: ffprobe not found.
Install with: brew install ffmpeg
```

and exits before all of the following:

- creating the requested output directory;
- invoking a media metadata command;
- writing `metadata.txt`;
- invoking `ffmpeg`; or
- reporting a duration or frame-extraction failure.

The output is fixed repository-owned text. No caller-provided URL or path is
interpolated into the dependency error, so the existing terminal-control
neutralization boundary remains unchanged.

## Resolution boundary

Callers may inject explicit `FFMPEG` and `FFPROBE` paths for packaged runtimes,
tests, Homebrew installations, containers, or other deployment layouts. When a
path is not injected, the script uses the shell's `command -v` lookup and retains
the existing Homebrew fallback path.

The preflight checks executability with `-x`; it does not execute an arbitrary
version probe. This keeps the dependency check deterministic and side-effect
free while leaving actual media compatibility to the normal bounded `ffprobe`
invocation. The script never searches the working directory for a helper and
never changes the terminal-output helper loading rule.

## Test-driven evidence

The regression was committed before the production condition. On the RED source
head, a real temporary video path plus an executable `FFMPEG` and a nonexistent
`FFPROBE` reached the metadata path and emitted the misleading duration error.
The production change then added the missing preflight immediately after the
existing `ffmpeg` check.

The regression requires all of the following:

- a real input-file path so file validation cannot mask the dependency failure;
- an executable injected `FFMPEG` so the earlier dependency gate passes;
- a nonexistent injected `FFPROBE`;
- exit status `1`;
- the exact missing-`ffprobe` diagnostic; and
- the actionable installation command.

Repository ShellCheck, CLI UX, terminal-control, SAST, security, and current-head
review gates remain authoritative before merge.

## Security and reliability implications

Failing at the dependency boundary reduces ambiguous control flow and prevents a
missing executable from being treated as malformed media. It does not claim that
an executable found on `PATH` is trustworthy; executable provenance remains an
installation and deployment responsibility. Production packaging should pin and
verify tool distributions where the product supplies FFmpeg itself.

The change also does not relax the existing controls for hostile paths, terminal
control characters, option injection, output-directory handling, or media
resource limits.

## Rollback

Rollback is a single production condition plus its regression and this record.
Rollback is appropriate only if the product removes `ffprobe` from the metadata
contract and replaces every consumed field with another explicitly validated
source. Silently returning to downstream duration failures is not an acceptable
rollback state.

## References

FFmpeg Project. (2026). *ffprobe documentation*. https://ffmpeg.org/ffprobe.html

The Open Group. (2024). *command*. In *POSIX.1-2024*. https://pubs.opengroup.org/onlinepubs/9799919799/utilities/command.html

These references are used as engineering guidance. This project does not claim
formal POSIX or FFmpeg conformance.
