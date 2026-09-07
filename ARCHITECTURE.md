# Architecture

`seedream_evasepic` is a Claude Code plugin. It turns one product brief into a
5-episode Seedream + Seedance prompt kit. Reference-video analysis is optional
and runs as local shell helpers.

```mermaid
flowchart LR
  brief["Product brief"] --> kit["product-series-kit"]
  url["Reference URL or file"] --> download["download-reference.sh"]
  download --> frames["extract-frames.sh"]
  frames --> transcribe["transcribe.sh"]
  transcribe --> analyze["analyze-reference-video"]
  analyze --> kit
  kit --> pair["generate-prompt-pair"]
  pair --> out["10 paired prompts"]
```

## Standalone vs module

Each helper must succeed on its own with two arguments and an actionable
stderr path. When the plugin is imported as a marketplace module, the same
scripts are the analysis backend. Do not hide required tools behind a
workspace-only wrapper.

## Authority records

| Decision | Record |
| --- | --- |
| Cache-hit skip | `docs/doctoring/download-cache-hit.md` |
| IEC file size | `docs/doctoring/iec-file-size.md` |
| ffprobe preflight | `docs/doctoring/ffprobe-dependency-preflight.md` |
| Terminal neutralization | `docs/doctoring/terminal-output-neutralization.md` |

## Next buyer action

If a cached reference looks like a stub, delete that path and run
`download-reference.sh` again. Then continue episode planning.
