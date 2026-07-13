# AGENTS.md

Cross-agent conventions for `seedream_evasepic` — readable by any coding agent
(Claude, Codex, Cursor, opencode, …). This repo is a Claude Code plugin:
Shell helper scripts, Markdown skills, and YAML templates. Keep changes minimal
and idempotent; docs are English.

<!-- BEGIN cwl-agent-guidance -->
## Agent guidance (CWL governance)

### Security & review gate
- Every PR runs a central **Security Scan** required gate: `osv-scan` +
  `dependency-review` (diff-scoped) and `trivy-fs` (repo-wide, CRITICAL/HIGH,
  fixable). It runs on every PR base, **including stacked PRs**.
- A **failing `trivy-fs` is a REAL finding, not a flake.** Read the job log (it
  prints each finding's rule id / severity / file) or the run's SARIF results,
  then **remediate**. This repo has no dependency lockfiles, Dockerfile, or k8s
  manifests, so findings here are most likely a misconfig or a leaked secret in
  a shell script (`plugins/**/scripts/*.sh`, `test_cli_ux.sh`) or a YAML
  template (`plugins/**/*.yaml`) — fix the offending config/script. If a
  dependency manifest is ever added, bump the flagged package instead. For a
  genuine false positive, add a narrow, documented `.trivyignore.yaml` entry.
  **Never weaken or disable the gate.**
- Reproduce locally against the merge ref, not just the PR head — and refresh
  the DB first, or a stale local DB will miss findings:
  ```
  trivy --download-db-only
  trivy fs --severity CRITICAL,HIGH --ignore-unfixed .
  ```
- The org `code_scanning` ruleset is intentionally **CodeQL-only** (multiple
  code-scanning tools can't converge on one PR ref). Gating is by the Security
  Scan **job result**, not the `code_scanning` rule — don't add tools to it.

### Code exploration
- There is no `.codegraph/` index in this repo, so use normal search
  (grep/find/ripgrep) to locate and understand code. If a `.codegraph/` index
  is added at the repo root later, prefer CodeGraph
  (`codegraph explore "<query>"`, or the code-review-graph MCP tools) BEFORE
  grep/find — it surfaces callers/callees/impact that text search misses.
<!-- END cwl-agent-guidance -->
