# Reference-video download cache-hit contract

## Buyer-visible decision

`download-reference.sh` treats the caller-selected output path as an explicit
local cache key. When that path already resolves to a non-empty regular file,
the command returns success before dependency discovery, package installation,
output-directory creation, or any `yt-dlp` network request. The existing bytes
remain untouched.

This behavior removes repeat network latency and bandwidth use for idempotent
workflows that deliberately reuse the same output path. It also makes the skip
visible: the CLI reports `File already exists, skipping download:` followed by
the path through the shared terminal-output neutralizer, then the same IEC
`Size:` line used after a fresh download. Use that size to confirm the cached
file is a real video before the next analysis step. See
`docs/doctoring/iec-file-size.md`.

## Boundary conditions

The cache predicate is deliberately narrow:

- `-f` requires the output to resolve to a regular file;
- `-s` requires a size greater than zero;
- a missing path remains a cache miss;
- a zero-byte regular file remains a cache miss; and
- directories are not cache hits.

GNU Bash documents `-f` and `-s` as file conditional expressions. The compound
predicate is evaluated before `command -v yt-dlp`, so a valid local cache hit
does not require `yt-dlp` to be installed.

The output path is caller-owned. This shortcut does not prove that the existing
artifact was produced from the currently supplied URL, validate media integrity,
or provide a content-addressed cache. A caller that needs a fresh artifact must
choose a different output path or remove the old file before invoking the
command. This limitation is explicit rather than silently delegating overwrite
semantics to `yt-dlp`.

## Security and rendering invariants

The original path is used only for filesystem predicates. It is never inserted
into a `%b` format or interpreted as shell source. Status output passes the path
to `terminal_print_value`, which preserves the terminal-control neutralization
contract introduced by the ANSI-injection repair. The cache-hit branch performs
no external filename-rendering command such as `ls`.

The shortcut does not weaken the existing `--` separator protecting the URL
argument passed to `yt-dlp`, and it does not modify the original URL or path
before process or filesystem use.

## Test-first evidence

Exact test-only head `b67911afc42f8a37e0018c072f863c5442078eab`
ran ShellCheck successfully and then failed the executable CLI contract because
`yt-dlp` was still invoked for a non-empty cached artifact. The regression log
captured the complete argument vector, including the cached output path and
original URL.

The permanent contract covers every new predicate outcome:

- an existing non-empty regular file exercises the cache-hit branch, proves
  `yt-dlp` is not invoked, verifies exit status zero, and checks byte-for-byte
  preservation;
- an existing zero-byte regular file exercises the size-false branch and proves
  `yt-dlp` receives the original URL; and
- the existing missing-output test exercises the file-false branch while
  retaining the `--` argument-separator invariant.

`.github/workflows/cli-ux.yml` checks out the literal pull-request head with
persisted credentials disabled, runs ShellCheck at warning-or-higher severity,
executes the complete CLI and terminal-neutralization suites, and verifies a
clean worktree. The workflow has read-only repository permissions and immutable
action pins.

## Rollback

If product requirements change to mandate a refresh on every invocation, remove
the early-return block together with its cache-hit tests and this contract. Do
not retain documentation claiming network short-circuiting after the behavior
is removed. A future force-refresh option must be specified and tested as a
separate interface change rather than bypassing this predicate implicitly.

## References

Free Software Foundation. (n.d.). *Bash conditional expressions*. GNU Bash
Reference Manual. Retrieved August 6, 2026, from
https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html

yt-dlp contributors. (n.d.). *yt-dlp README* [Software documentation]. GitHub.
Retrieved August 6, 2026, from
https://github.com/yt-dlp/yt-dlp/blob/master/README.md
