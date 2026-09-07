# Named missing-argument diagnostics

## Decision

The three reference-media shell entrypoints name the exact missing positional
argument, reprint the existing colored usage and example block on standard
error, and exit with status `2` before dependency discovery, package
installation, media probing, or network work.

A combined “missing required argument(s)” message forces the caller to guess
which operand is absent. Naming `<url>`, `<output_path>`, `<video_path>`,
`<output_dir>`, or `<audio_path>` makes the next command correction immediate.

## User-visible contract

| Command | Missing operand | Diagnostic fragment |
|---|---|---|
| `download-reference.sh` | first | `Error: Missing required argument: <url>` |
| `download-reference.sh` | second | `Error: Missing required argument: <output_path>` |
| `extract-frames.sh` | first | `Error: Missing required argument: <video_path>` |
| `extract-frames.sh` | second | `Error: Missing required argument: <output_dir>` |
| `transcribe.sh` | first | `Error: Missing required argument: <audio_path>` |

Every path above must:

- write the named error, the yellow usage line, and the cyan example to stderr;
- exit `2`;
- leave download, ffmpeg, transcription, credential, and output-path semantics
  unchanged; and
- treat whitespace-only operands as present, matching the pre-change `-z`
  predicate. Tightening that rule is a separate validation change.

The diagnostic strings are repository-owned literals. No caller-supplied URL or
path is interpolated into the missing-argument error, so the terminal-control
neutralization boundary is not widened.

## Test-driven evidence

`test_cli_ux.sh` must not judge these paths with `script | grep`. That suite
does not enable `pipefail`, so grep’s status would hide a successful or
wrong-status exit that still printed the text.

Each invocation is captured under a tool-free `PATH` that contains only
`dirname` (required to resolve `SCRIPT_DIRECTORY`). The harness then requires
both of the following before grepping:

- exit status `2`; and
- the exact targeted error fragment.

The restricted `PATH` excludes `yt-dlp`, `brew`, `pip3`, `pip`, `ffmpeg`,
`ffprobe`, and `whisper`. If a missing-argument guard regresses, the command
fails closed with a non-2 status instead of reaching auto-install or network
work. The `dummy_url` second-operand case is the regression that would otherwise
reach download or install.

## Security and reliability implications

Naming the missing operand does not grant new filesystem, network, or
credential authority. It also does not claim POSIX utility-syntax conformance.
The scripts continue to use repository-owned usage text rather than a generated
synopsis.

## Rollback

Rollback is the named `if`/`elif` splits, the targeted tests, and this record.
Returning to a single combined missing-argument sentence is acceptable only if
the product also drops the first-versus-second operand distinction from the
published CLI contract.

## References

International Organization for Standardization. (2020). *Ergonomics of
human-system interaction — Part 110: Interaction principles*
(ISO 9241-110:2020). https://www.iso.org/standard/75258.html

Nielsen Norman Group. (2024). *10 usability heuristics for user interface
design*. https://www.nngroup.com/articles/ten-usability-heuristics/

The Open Group. (2024). *Utility conventions*. In *POSIX.1-2024*.
https://pubs.opengroup.org/onlinepubs/9799919799/basedefs/V1_chap12.html

These references are used as engineering guidance. This project does not claim
formal ISO 9241 or POSIX conformance.
