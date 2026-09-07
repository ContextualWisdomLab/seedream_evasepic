# CLAUDE.md

Follow `AGENTS.md` for org gates and `ARCHITECTURE.md` for product boundaries.

This repository is a Claude Code plugin: Markdown skills, YAML templates, and
Bash helpers. Keep changes minimal and idempotent. Docs stay in English.

When a buyer-visible CLI contract changes, update the matching file under
`docs/doctoring/` and add a real-byte test in `test_cli_ux.sh` before merging.
