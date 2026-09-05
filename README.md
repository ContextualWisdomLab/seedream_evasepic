# seedream_evasepic

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ContextualWisdomLab/seedream_evasepic)

**Turn one product brief into a coordinated five-episode Seedream image + Seedance video prompt kit.**

`seedream_evasepic` is a Claude Code plugin for planning short-form product campaigns, with an existing K-beauty/cosmetics focus. It can produce five linked episode concepts, pair each episode with image/video prompt guidance, and optionally analyze a reference video before composing the series.

> **Fork provenance:** `ContextualWisdomLab/seedream_evasepic` is a fork of [`passeth/seedream_evasepic`](https://github.com/passeth/seedream_evasepic). Upstream remains the original plugin/source authority. Fork-specific changes and verification must be evaluated from this repository's exact revision.

## What it helps you do

- Turn a product brief into a five-episode Hook → Benefit → Demo → Testimonial → CTA plan.
- Keep image and video prompt guidance aligned across the series.
- Analyze a supplied reference video into a reusable style description when the local media tools are available.
- Generate one image/video prompt pair without running the full five-episode workflow.
- Reuse the included K-beauty mood, camera, episode, and series templates as starting points.

The plugin generates prompt material. It does **not** operate Seedream, Seedance, Dreamina, fal.ai, or another model provider on your behalf, and it does not make those providers' availability, model behavior, terms, or generated-output rights part of this repository's authority.

## Quick start

The upstream marketplace declaration is retained in this fork and points to the plugin under `plugins/seedream-evasepic`.

To use the upstream marketplace directly:

```text
/plugin marketplace add https://github.com/passeth/seedream_evasepic.git
/plugin install seedream-evasepic
```

To evaluate ContextualWisdomLab changes before upstream adoption, use this repository as the source under review and bind your evaluation to an exact commit. Do not assume an upstream marketplace installation contains an open fork PR.

After installation, restart Claude Code and provide a product brief. For example:

```text
제품: 세라마이드 앰플
특징: 고농축 세라마이드, 민감성 진정
모델: 30대 초반 여성, 전문가적 신뢰감
무드: 클리니컬 미니멀, 따뜻한 화이트톤
플랫폼: 인스타 릴스 (9:16)
참고영상: https://www.youtube.com/watch?v=...   # 선택
→ 5-에피소드 시리즈로 만들어줘
```

The workflow is expected to return a connected five-episode plan, paired image/video prompt guidance, and a QA-oriented handoff. Treat provider-specific prompt constraints as changeable external behavior and verify them against the provider's current documentation before production use.

## Reference-video workflow

Reference-video analysis uses repository shell helpers around local media/download/transcription tools. Current requirements are:

- Claude Code;
- `ffmpeg` and `ffprobe` for frame/media analysis;
- `yt-dlp` when a supported remote video must be downloaded;
- Whisper when local transcription is requested.

The current branch contains explicit CLI tests and doctoring notes for download cache hits, independent `ffprobe` preflight, terminal-output neutralization, and safe path handling. These checks improve the local helper boundary; they do not grant permission to download, transcribe, or reuse third-party media. The operator remains responsible for source-site terms and content rights.

## Product structure

Three skills compose the plugin:

| Skill | Responsibility |
| --- | --- |
| `product-series-kit` | Product brief → coordinated five-episode series plan and paired prompts |
| `analyze-reference-video` | Reference video/file → bounded local analysis and reusable style description |
| `generate-prompt-pair` | One image/video prompt pair for a single episode |

Supporting material includes episode archetypes, K-beauty mood references, prompt templates, series templates, provider-oriented references, and curated prompt examples.

## Verification

This fork includes shell-level regression tests for its helper scripts. Run the checks relevant to the surface you change and use GitHub Checks on the unchanged exact PR head as hosted evidence.

```bash
bash test_cli_ux.sh
bash test_terminal_output.sh
```

Do not transfer a passing result from an earlier head after documentation, scripts, templates, or workflow bytes change.

## Current status

This repository is an organization-maintained fork, not a separately published product release channel. Source/plugin metadata may carry a version, but that is not by itself immutable fork release evidence. Verify the current GitHub Releases inventory, protected branch, exact commit, checks, and review state before distribution or deployment decisions.

## Attribution and licensing status

Licensing needs two separate answers: the grant for the original `seedream_evasepic` source, and the terms of external material incorporated or adapted inside the plugin.

The upstream README says `MIT`, and `.claude-plugin/marketplace.json` also declares `MIT`, but the upstream repository currently has **no root LICENSE file**, GitHub reports no detected license, and the available upstream source does not contain the complete MIT copyright/permission notice that a redistributor would need to preserve. This fork therefore does **not** invent a new ContextualWisdomLab copyright notice or present `MIT — use freely` as a fully resolved redistribution grant. Commercial redistribution remains provenance-blocked until the upstream rightsholder supplies or confirms the complete source-license notice (including the copyright notice to retain), or equivalent rights evidence is established.

The repository also states that its curated prompt material was pulled/distilled from external sources. In particular, `YouMind-OpenLab/awesome-seedance-2-prompts` is licensed under **CC BY 4.0**, which permits commercial use but requires attribution, a license link, and indication of changes. The repository now records that obligation in [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md). `krusemediallc/arcads-claude-code` is MIT-licensed and is recorded as an inspiration/source reference rather than silently absorbed into the fork's own licensing claim.

ByteDance/Seedream/Seedance documentation, model services, reference videos, generated media, Claude Code, ffmpeg, yt-dlp, Whisper, and other external tools/services retain their own terms. This repository does not relicense them.

## Documentation and support

- [`CHANGELOG.md`](CHANGELOG.md) — fork development history.
- [`docs/doctoring`](docs/doctoring) — executable failure-boundary notes for the helper scripts.
- [`plugins/seedream-evasepic/skills`](plugins/seedream-evasepic/skills) — skill contracts, templates, references, and examples.
- [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) — incorporated/derived material attribution and commercial-use obligations.
- [Ask DeepWiki](https://deepwiki.com/ContextualWisdomLab/seedream_evasepic) — repository-grounded navigation and questions.
- [Upstream repository](https://github.com/passeth/seedream_evasepic) — original plugin/source authority.

For fork-specific defects or changes, use this repository's issues and pull requests. For upstream plugin behavior or release authority, use the upstream project. When changing curated prompts or external references, record source identity, license, attribution, and whether the material was copied, adapted, or merely consulted.
